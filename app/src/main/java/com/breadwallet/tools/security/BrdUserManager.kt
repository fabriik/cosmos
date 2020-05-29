/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 8/12/19.
 * Copyright (c) 2019 breadwallet LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.breadwallet.tools.security

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.UserNotAuthenticatedException
import android.text.format.DateUtils
import androidx.core.content.edit
import androidx.core.content.getSystemService
import androidx.lifecycle.Lifecycle
import com.breadwallet.app.ApplicationLifecycleObserver
import com.breadwallet.app.BreadApp
import com.breadwallet.crypto.Account
import com.breadwallet.crypto.Key
import com.breadwallet.logger.logInfo
import com.breadwallet.tools.crypto.CryptoHelper.hexDecode
import com.breadwallet.tools.crypto.CryptoHelper.hexEncode
import com.breadwallet.tools.manager.BRSharedPrefs
import com.platform.interfaces.AccountMetaDataProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.BroadcastChannel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.Channel.Factory.CONFLATED
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.flow.transformLatest
import kotlinx.coroutines.invoke
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.util.Date
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import kotlin.math.pow

const val PIN_LENGTH = 6
const val LEGACY_PIN_LENGTH = 4
private const val MAX_UNLOCK_ATTEMPTS = 3
private const val JWT_EXP_PADDING_MS = 10_000L

/** Manages creation, recovery, and access to an [Account]. */
@Suppress("TooManyFunctions")
interface BrdUserManager {
    suspend fun setupWithGeneratedPhrase(): SetupResult
    suspend fun setupWithPhrase(phrase: ByteArray): SetupResult
    suspend fun migrateKeystoreData(): Boolean

    suspend fun checkAccountInvalidated()

    fun isInitialized(): Boolean
    fun getState(): BrdUserState
    fun stateChanges(disabledUpdates: Boolean = false): Flow<BrdUserState>

    fun isMigrationRequired(): Boolean

    suspend fun getPhrase(): ByteArray?
    fun getAccount(): Account?
    fun updateAccount(accountBytes: ByteArray)
    fun getAuthKey(): ByteArray?

    suspend fun configurePinCode(pinCode: String)
    suspend fun clearPinCode(phrase: ByteArray)
    fun verifyPinCode(pinCode: String): Boolean
    fun hasPinCode(): Boolean
    fun pinCodeNeedsUpgrade(): Boolean

    fun lock()
    fun unlock()

    fun getToken(): String?
    fun putToken(token: String)

    fun getBdbJwt(): String?
    fun putBdbJwt(jwt: String, exp: Long)

    fun onActivityResult(requestCode: Int, resultCode: Int)
}

private const val POLL_ATTEMPTS_MAX = 15
private const val POLL_TIMEOUT_MS = 1000L

private const val PUT_PHRASE_RC = 400
private const val GET_PHRASE_RC = 401

private const val KEY_ACCOUNT = "account"
private const val KEY_AUTH_KEY = "authKey"
private const val KEY_CREATION_TIME = "creationTimeSeconds"
private const val KEY_TOKEN = "token"
private const val KEY_BDB_JWT = "bdbJwt"
private const val KEY_BDB_JWT_EXP = "bdbJwtExp"
private const val KEY_PIN_CODE = "pinCode"
private const val KEY_FAIL_COUNT = "failCount"
private const val KEY_FAIL_TIMESTAMP = "failTimestamp"
private const val KEY_ETH_PUB_KEY = "ethPublicKey"

@Suppress("TooManyFunctions")
class CryptoUserManager(
    private val createStore: () -> SharedPreferences?,
    private val metaDataProvider: AccountMetaDataProvider
) : BrdUserManager {

    private var store: SharedPreferences? = null

    // TODO: Remove this once BRKeyStore auth screen logic is refactored
    private val context get() = BreadApp.getBreadContext()
    private val keyguard = checkNotNull(context.getSystemService<KeyguardManager>())

    private val mutex = Mutex()

    private val resultChannel = Channel<Int>()
    private val stateChangeChannel = BroadcastChannel<Unit>(CONFLATED)

    private val invalidated = AtomicBoolean()
    private val keyStoreStatus = AtomicReference<KeyStoreStatus>()
    private val locked = AtomicBoolean(false)
    private val disabledSeconds = AtomicInteger(0)
    private var token: String? = null
    private var jwt: String? = null
    private var jwtExp: Long? = null

    init {
        val newStore = createStore()
        val currentStatus = BRKeyStore.getValidityStatus()
        keyStoreStatus.set(currentStatus)

        if (newStore != null && currentStatus == KeyStoreStatus.VALID) {
            store = newStore
            startDisabledTimer(getFailTimestamp())
        }
        stateChangeChannel.offer(Unit)

        ApplicationLifecycleObserver.addApplicationLifecycleListener { event ->
            if (event == Lifecycle.Event.ON_START) {
                val newStatus = BRKeyStore.getValidityStatus()
                if (keyStoreStatus.get() != newStatus) {
                    if (BRKeyStore.getValidityStatus() == KeyStoreStatus.VALID) {
                        val nextStore = createStore()
                        if (nextStore != null) {
                            store = nextStore
                        }
                    } else {
                        store = null
                    }
                    keyStoreStatus.set(newStatus)
                    stateChangeChannel.offer(Unit)
                }
            }
        }
    }

    override suspend fun setupWithGeneratedPhrase(): SetupResult {
        val creationDate = Date()
        val phrase = try {
            generatePhrase()
        } catch (e: Exception) {
            return SetupResult.FailedToGeneratePhrase(e)
        }
        return initAccount(phrase, creationDate).also {
            withContext(Dispatchers.IO) {
                metaDataProvider.create(creationDate)
            }
        }
    }

    override suspend fun setupWithPhrase(phrase: ByteArray): SetupResult {
        val apiKey = Key.createForBIP32ApiAuth(
            phrase,
            Key.getDefaultWordList()
        ).orNull() ?: return SetupResult.FailedToCreateApiKey

        checkNotNull(store).edit {
            putBytes(KEY_AUTH_KEY, apiKey.encodeAsPrivate())
        }
        val creationDate = recoverCreationDate()
        return initAccount(phrase, creationDate, apiKey)
    }

    override suspend fun migrateKeystoreData() = mutex.withLock {
        // Migrate fields required for Account
        val phrase = getPhrase() ?: return@withLock false
        try {
            val creationDate = Date(BRKeyStore.getWalletCreationTime(context))
            val account =
                Account.createFromPhrase(phrase, creationDate, BRSharedPrefs.getDeviceId()).get()
            val apiKey = Key.createForBIP32ApiAuth(
                phrase,
                Key.getDefaultWordList()
            ).orNull()

            checkNotNull(apiKey) { "Migration failed, failed to create Api Key." }

            writeAccount(account, apiKey, creationDate)
        } catch (e: Exception) {
            wipeAccount()
            return@withLock false
        }

        // Migrate other fields
        BRKeyStore.getToken(context)?.let { putToken(String(it)) }
        BRKeyStore.getBdbJwt(context)
            ?.let { putBdbJwt(String(it), BRKeyStore.getBdbJwtExp(context)) }
        BRKeyStore.getEthPublicKey(context)?.let { putEthPublicKey(it) }
        putPinCode(BRKeyStore.getPinCode(context))
        putFailCount(BRKeyStore.getFailCount(context))
        putFailTimestamp(BRKeyStore.getFailTimeStamp(context))

        BreadApp.applicationScope.launch(Dispatchers.IO) {
            BRKeyStore.wipeAfterMigration(context)
        }

        true
    }

    override suspend fun checkAccountInvalidated() {
        val deviceId = BRSharedPrefs.getDeviceId()
        val invalidated = checkNotNull(store).getBytes(KEY_ACCOUNT, null)?.let {
            Account.createFromSerialization(it, deviceId).orNull() == null
        } ?: false

        if (!invalidated) return
        val phrase = getPhrase()
        if (phrase == null) {
            this.invalidated.set(true)
            stateChangeChannel.offer(Unit)
            return
        }

        logInfo("Account needs to be re-created from phrase.")

        val account = Account.createFromPhrase(
            phrase,
            Date(getWalletCreationTime()),
            deviceId
        ).orNull()

        if (account == null) {
            this.invalidated.set(true)
            stateChangeChannel.offer(Unit)
        } else {
            logInfo("Account re-created.")
            checkNotNull(store).edit {
                putBytes(KEY_ACCOUNT, account.serialize())
            }
        }
    }

    override fun isInitialized() = getState() != BrdUserState.Uninitialized

    override fun isMigrationRequired() =
        !isInitialized() &&
            (BRKeyStore.getMasterPublicKey(context) != null || BRKeyStore.hasAccountBytes(context))

    override fun getState(): BrdUserState {
        if (invalidated.get()) {
            return BrdUserState.KeyStoreInvalid.Uninstall
        }
        if (!keyguard.isKeyguardSecure) {
            return BrdUserState.KeyStoreInvalid.Lock
        }
        when (keyStoreStatus.get()) {
            KeyStoreStatus.VALID -> Unit // Ignore
            KeyStoreStatus.INVALID_UNINSTALL ->
                return BrdUserState.KeyStoreInvalid.Uninstall
            KeyStoreStatus.INVALID_WIPE ->
                return BrdUserState.KeyStoreInvalid.Wipe
            else -> if (store == null) {
                return if (BRKeyStore.requiresUninstall()) {
                    BrdUserState.KeyStoreInvalid.Uninstall
                } else {
                    BrdUserState.KeyStoreInvalid.Wipe
                }
            }
        }

        if (getAccount() == null) return BrdUserState.Uninitialized
        return when {
            disabledSeconds.get() > 0 -> {
                BrdUserState.Disabled(disabledSeconds.get())
            }
            locked.get() -> BrdUserState.Locked
            else -> BrdUserState.Enabled
        }
    }

    override fun stateChanges(disabledUpdates: Boolean): Flow<BrdUserState> =
        stateChangeChannel.asFlow()
            .onStart { emit(Unit) }
            .map { getState() }
            .transformLatest { state ->
                if (state is BrdUserState.Disabled && disabledUpdates) {
                    emit(state)
                    while (disabledSeconds.get() > 0) {
                        delay(1000)
                        emit(state.copy(seconds = disabledSeconds.get()))
                    }
                } else emit(state)
            }
            .distinctUntilChanged()
            .flowOn(Default)

    override suspend fun getPhrase(): ByteArray? =
        executeWithAuth { BRKeyStore.getPhrase(it, GET_PHRASE_RC) }

    override fun getAccount(): Account? =
        checkNotNull(store).getBytes(KEY_ACCOUNT, null)?.run {
            Account.createFromSerialization(
                this,
                BRSharedPrefs.getDeviceId()
            ).orNull()
        }

    override fun updateAccount(accountBytes: ByteArray) {
        checkNotNull(
            Account.createFromSerialization(
                accountBytes,
                BRSharedPrefs.getDeviceId()
            ).orNull()
        )
        checkNotNull(store).edit { putBytes(KEY_ACCOUNT, accountBytes) }
    }

    override fun getAuthKey() = checkNotNull(store).getBytes(KEY_AUTH_KEY, null)

    override suspend fun configurePinCode(pinCode: String) {
        checkNotNull(getPhrase()) { "Phrase is null, cannot set pin code." }
        check(pinCode.length == PIN_LENGTH && pinCode.toIntOrNull() != null) {
            "Invalid pin code."
        }

        putPinCode(pinCode)
        putFailCount(0)
    }

    override suspend fun clearPinCode(phrase: ByteArray) {
        val storedPhrase = checkNotNull(getPhrase()) { "Phrase is null, cannot clear pin code." }
        check(phrase.contentEquals(storedPhrase)) { "Phrase does not match." }
        putPinCode("")
        putFailCount(0)
        putFailTimestamp(0)
        disabledSeconds.set(0)
        locked.set(false)
        stateChangeChannel.offer(Unit)
    }

    override fun verifyPinCode(pinCode: String) =
        if (pinCode == getPinCode()) {
            putFailCount(0)
            putFailTimestamp(0)
            locked.set(false)
            stateChangeChannel.offer(Unit)
            true
        } else {
            val failCount = getFailCount() + 1
            putFailCount(failCount)
            if (failCount >= MAX_UNLOCK_ATTEMPTS) {
                BRSharedPrefs.getSecureTime()
                    .also(::putFailTimestamp)
                    .also(::startDisabledTimer)
                stateChangeChannel.offer(Unit)
            }
            false
        }

    override fun hasPinCode() = getPinCode().isNotBlank()

    override fun pinCodeNeedsUpgrade() =
        getPinCode().let { it.isNotBlank() && it.length != PIN_LENGTH }

    override fun lock() {
        if (!locked.getAndSet(true)) {
            stateChangeChannel.offer(Unit)
        }
    }

    override fun unlock() {
        if (locked.getAndSet(false)) {
            stateChangeChannel.offer(Unit)
        }
    }

    @Synchronized
    override fun getToken() = token ?: checkNotNull(store).getString(KEY_TOKEN, null)

    @Synchronized
    override fun putToken(token: String) {
        checkNotNull(store).edit { putString(KEY_TOKEN, token) }
        this.token = token
    }

    @Synchronized
    override fun getBdbJwt() =
        if ((getBdbJwtExp() - JWT_EXP_PADDING_MS) <= System.currentTimeMillis()) {
            null
        } else {
            jwt ?: checkNotNull(store).getString(KEY_BDB_JWT, null)
        }

    @Synchronized
    override fun putBdbJwt(jwt: String, exp: Long) {
        checkNotNull(store).edit {
            putString(KEY_BDB_JWT, jwt)
            putLong(KEY_BDB_JWT_EXP, exp)
        }
        this.jwt = jwt
        this.jwtExp = exp
    }

    @Synchronized
    private fun getBdbJwtExp() =
        jwtExp ?: checkNotNull(store).getLong(KEY_BDB_JWT_EXP, 0)

    /**
     * Used to determine address mismatch cases for tracking purposes, therefore exposed
     * as part of the implementation rather than the [BrdUserManager] interface.
     */
    fun getEthPublicKey(): ByteArray? =
        checkNotNull(store).getBytes(KEY_ETH_PUB_KEY, null)

    private fun generatePhrase(): ByteArray {
        val words = Key.getDefaultWordList()
        return Account.generatePhrase(words).also { phrase ->
            check(Account.validatePhrase(phrase, words)) {
                "Invalid phrase generated."
            }
        }
    }

    private suspend fun initAccount(phrase: ByteArray, creationDate: Date, apiKey: Key? = null) =
        mutex.withLock {
            check(getPhrase() == null) { "Phrase already exists." }

            try {
                val storedPhrase = executeWithAuth {
                    BRKeyStore.putPhrase(phrase, context, PUT_PHRASE_RC)
                    BRKeyStore.getPhrase(context, GET_PHRASE_RC)
                } ?: return@withLock SetupResult.FailedToPersistPhrase

                val account = Account.createFromPhrase(
                    storedPhrase,
                    creationDate,
                    BRSharedPrefs.getDeviceId()
                ).get() ?: return@withLock SetupResult.FailedToCreateAccount

                val apiAuthKey = apiKey ?: Key.createForBIP32ApiAuth(
                    phrase,
                    Key.getDefaultWordList()
                ).orNull() ?: return@withLock SetupResult.FailedToCreateApiKey

                writeAccount(account, apiAuthKey, creationDate)

                if (
                    !validateAccount(
                        storedPhrase,
                        account,
                        apiAuthKey,
                        creationDate.time
                    )
                ) return@withLock SetupResult.FailedToCreateValidWallet

                locked.set(false)
                stateChangeChannel.offer(Unit)
                logInfo("Account created.")
                SetupResult.Success
            } catch (e: Exception) {
                wipeAccount()
                SetupResult.UnknownFailure(e)
            }
        }

    private fun getPinCode() =
        checkNotNull(store).getString(KEY_PIN_CODE, "") ?: ""

    private fun putEthPublicKey(ethPubKey: ByteArray) =
        checkNotNull(store).edit { putBytes(KEY_ETH_PUB_KEY, ethPubKey) }

    private fun getWalletCreationTime() =
        checkNotNull(store).getLong(KEY_CREATION_TIME, 0L)

    private fun disabledUntil(failCount: Int, failTimestamp: Long): Long {
        val pow =
            PIN_LENGTH.toDouble()
                .pow((failCount - MAX_UNLOCK_ATTEMPTS).toDouble()) * DateUtils.MINUTE_IN_MILLIS
        return (failTimestamp + pow).toLong()
    }

    private fun putPinCode(pinCode: String) {
        checkNotNull(store).edit { putString(KEY_PIN_CODE, pinCode) }
    }

    private fun getFailCount() =
        checkNotNull(store).getInt(KEY_FAIL_COUNT, 0)

    private fun putFailCount(count: Int) =
        checkNotNull(store).edit { putInt(KEY_FAIL_COUNT, count) }

    private fun getFailTimestamp(): Long =
        checkNotNull(store).getLong(KEY_FAIL_TIMESTAMP, 0)

    private fun putFailTimestamp(timestamp: Long) =
        checkNotNull(store).edit { putLong(KEY_FAIL_TIMESTAMP, timestamp) }

    private fun startDisabledTimer(failTimestamp: Long) {
        if (failTimestamp > 0) {
            GlobalScope.launch {
                val secureTime = BRSharedPrefs.getSecureTime()
                val disableUntil = disabledUntil(getFailCount(), failTimestamp)
                val delaySeconds = ((disableUntil - secureTime) / 1000).toInt()

                if (delaySeconds <= 0) {
                    return@launch
                }

                disabledSeconds.set(delaySeconds)
                while (disabledSeconds.get() > 0) {
                    delay(1000)
                    disabledSeconds.getAndDecrement()
                }

                putFailTimestamp(0)
                disabledSeconds.set(0)
                stateChangeChannel.offer(Unit)
            }
        }
    }

    /**
     * Invokes [action], catching [UserNotAuthenticatedException].
     * If authentication is required, it will be attempted and upon
     * success will invoke [action] again. If authentication fails,
     * null is returned.
     */
    private suspend fun <T> executeWithAuth(action: (context: Context) -> T): T {
        val activity = getActivity()
        return try {
            Main {
                runCatching { action(activity) }
            }.getOrThrow()
        } catch (e: UserNotAuthenticatedException) {
            logInfo("Attempting authentication")

            when (resultChannel.receive()) {
                Activity.RESULT_OK -> Main {
                    runCatching { action(activity) }
                }.getOrThrow()
                else -> throw e
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int) {
        check(!resultChannel.isClosedForSend)

        resultChannel.offer(
            when (requestCode) {
                PUT_PHRASE_RC -> resultCode
                GET_PHRASE_RC -> resultCode
                else -> return
            }
        )
    }

    private suspend fun recoverCreationDate(): Date {
        BreadApp.applicationScope.launch {
            metaDataProvider.recoverAll(true).first()
        }
        return metaDataProvider.walletInfo()
            .onStart {
                // Poll for wallet-info metadata
                // This is a work-around to avoid blocking until recoverAll(migrate)
                // recovers *all* metadata
                for (i in 1..POLL_ATTEMPTS_MAX) {
                    metaDataProvider.getWalletInfoUnsafe()
                        ?.let { emit(it) }
                    delay(POLL_TIMEOUT_MS)
                }
            }
            .first()
            .creationDate
            .run(::Date)
    }

    private fun writeAccount(
        account: Account,
        apiKey: Key,
        creationDate: Date
    ) {
        checkNotNull(store).edit {
            putBytes(KEY_ACCOUNT, account.serialize())
            putBytes(KEY_AUTH_KEY, apiKey.encodeAsPrivate())
            putLong(KEY_CREATION_TIME, creationDate.time)
        }
    }

    private suspend fun validateAccount(
        phrase: ByteArray,
        account: Account,
        apiKey: Key,
        creationTime: Long
    ) = withContext(Dispatchers.IO) {
        Account.validatePhrase(phrase, Key.getDefaultWordList()) &&
            getAccount()?.serialize()?.contentEquals(account.serialize()) == true &&
            getAuthKey()?.contentEquals(apiKey.encodeAsPrivate()) == true &&
            getWalletCreationTime() == creationTime
    }

    private fun wipeAccount() {
        BRKeyStore.deletePhrase(context)
        checkNotNull(store).edit {
            putString(KEY_ACCOUNT, null)
            putString(KEY_AUTH_KEY, null)
            putLong(KEY_CREATION_TIME, 0)
        }
    }

    private suspend fun getActivity(): Activity {
        while (context !is Activity) delay(1_000)
        return context as Activity
    }
}

fun SharedPreferences.getBytes(key: String, defaultValue: ByteArray?): ByteArray? {
    val valStr = getString(key, null) ?: return defaultValue
    return hexDecode(valStr)
}

fun SharedPreferences.Editor.putBytes(key: String, value: ByteArray) {
    putString(key, hexEncode(value))
}

