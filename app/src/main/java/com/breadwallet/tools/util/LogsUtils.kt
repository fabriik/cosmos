/**
 * BreadWallet
 *
 * Created by Mihail Gutan on <mihail@breadwallet.com> 11/5/18.
 * Copyright (c) 2018 breadwallet LLC
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
package com.breadwallet.tools.util

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.Toast
import androidx.core.content.FileProvider
import com.breadwallet.BuildConfig
import com.breadwallet.R
import com.breadwallet.app.BreadApp.Companion.generateWalletId
import com.breadwallet.breadbox.BreadBox
import com.breadwallet.crypto.Address
import com.breadwallet.crypto.TransferState
import com.breadwallet.crypto.errors.TransferSubmitPosixError
import com.breadwallet.tools.manager.BRSharedPrefs.getBundleHash
import com.breadwallet.tools.manager.BRSharedPrefs.getDeviceId
import com.breadwallet.tools.manager.BRSharedPrefs.getWalletRewardId
import com.breadwallet.tools.security.BRAccountManager
import com.breadwallet.tools.security.CryptoAccountManager
import com.breadwallet.util.pubKeyToEthAddress
import org.apache.commons.io.IOUtils
import java.io.IOException
import java.util.Locale
import java.util.TimeZone

object LogsUtils {
    // Filters out our apps events at log level = verbose
    private const val LOGCAT_COMMAND = "logcat -d ${BuildConfig.APPLICATION_ID}:V"

    private const val DEFAULT_LOG_ATTACHMENT_BODY = "No logs."
    private const val FAILED_ERROR_MESSAGE = "Failed to get logs."
    private const val DEFAULT_LOGS_EMAIL = "android@brd.com"
    private const val NO_EMAIL_APP_ERROR_MESSAGE = "No email app found."
    private const val LOGS_EMAIL_SUBJECT = "BRD Android App Feedback [ID:%s]" // Placeholder is for a unique id.
    private const val LOGS_FILE_NAME = "Logs.txt"
    private const val MIME_TYPE = "text/plain"

    private fun getLogs(context: Context): String = try {
        val process = Runtime.getRuntime().exec(LOGCAT_COMMAND)
        IOUtils.toString(process.inputStream, Charsets.UTF_8)
    } catch (ex: IOException) {
        Toast.makeText(context, FAILED_ERROR_MESSAGE, Toast.LENGTH_LONG).show()
        DEFAULT_LOG_ATTACHMENT_BODY
    }

    private fun buildInfoString(
        context: Context,
        breadBox: BreadBox,
        accountManager: BRAccountManager
    ) = buildString {
        addFeedbackBlock()
        appendln()
        addApplicationBlock(context)
        appendln()
        addDeviceBlock()
        appendln()
        addWalletBlock(context, breadBox, accountManager)
    }

    private fun StringBuilder.addFeedbackBlock() {
        appendln("Feedback")
        appendln("------------")
        appendln("[Please add your feedback.]")
    }

    private fun StringBuilder.addApplicationBlock(context: Context) {
        appendln("Application (${BuildConfig.BUILD_TYPE})")
        appendln("------------")
        appendln("Package: ${BuildConfig.APPLICATION_ID}")
        appendln("Version: ${BuildConfig.VERSION_NAME} Build ${BuildConfig.BUILD_VERSION}")
        appendln(
            if (BuildConfig.BITCOIN_TESTNET) {
                "Network: Testnet"
            } else {
                "Network: Mainnet"
            }
        )
        for (bundleName in ServerBundlesHelper.getBundleNames(context)) {
            appendln("Bundle '$bundleName' version: ${getBundleHash(context, bundleName)}")
        }
    }

    private fun StringBuilder.addDeviceBlock() {
        appendln("Device")
        appendln("------------")
        appendln("Android Version: ${Build.VERSION.RELEASE}")
        appendln("Device Model: ${Build.MANUFACTURER} ${Build.MODEL}")
        appendln("Time Zone: ${TimeZone.getDefault().id}")
        appendln("Locale: ${Locale.getDefault().displayName}")
    }

    private fun StringBuilder.addWalletBlock(
        context: Context,
        breadBox: BreadBox,
        accountManager: BRAccountManager
    ) {
        appendln("Wallet")
        appendln("------------")
        appendln("Wallet id: ${getWalletRewardId(context)}")
        appendln("Device id: ${getDeviceId(context)}")
        breadBox.getSystemUnsafe()?.let { system ->
            system.walletManagers?.forEach { manager ->
                append("${manager.currency.name}: ")
                append("mode=${manager.mode.name}, ")
                append("state=${manager.state.type.name}, ")
                append("height=${manager.network.height}")
                appendln()
            }

            system.wallets
                .flatMap { wallet ->
                    wallet.transfers.filter { transfer ->
                        transfer.state.type == TransferState.Type.FAILED &&
                            !transfer.confirmation.isPresent
                    }
                }
                .forEach { transfer ->
                    val currencyCode = transfer.wallet.currency.code
                    val errorMessage = when (val transferError = transfer.state.failedError.orNull()) {
                        is TransferSubmitPosixError -> {
                            "Posix Error: ${transferError.errnum}, ${transferError.message}"
                        }
                        else -> "Unknown Error ${transferError?.message ?: ""}"
                    }
                    appendln("Failed $currencyCode Transfer: error='$errorMessage'")
                }

            if (accountManager is CryptoAccountManager) {
                val ethWallet = system.wallets
                    .firstOrNull { wallet ->
                        wallet.currency.code.equals("eth", true)
                    }
                val storedAddress = accountManager.getEthPublicKey().pubKeyToEthAddress()
                if (storedAddress != null && ethWallet != null) {
                    val network = ethWallet.walletManager.network
                    val coreAddress = Address.create(storedAddress, network).orNull()?.toString()
                    val walletAddress = ethWallet.target.toString()
                    if (!walletAddress.equals(coreAddress, true)) {
                        appendln("Stored Address: $storedAddress")
                        appendln("Stored Address Id: ${generateWalletId(storedAddress)}")
                    }
                }
            }
        }
    }

    fun shareLogs(context: Context, breadBox: BreadBox, accountManager: BRAccountManager) {
        val file = FileHelper.saveToExternalStorage(context, LOGS_FILE_NAME, getLogs(context))
        val uri = FileProvider.getUriForFile(context, BuildConfig.APPLICATION_ID, file)
        val emailIntent = Intent(Intent.ACTION_SEND).apply {
            type = MIME_TYPE
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_EMAIL, arrayOf(DEFAULT_LOGS_EMAIL))
            putExtra(
                Intent.EXTRA_SUBJECT,
                String.format(LOGS_EMAIL_SUBJECT, getDeviceId(context))
            )
            putExtra(Intent.EXTRA_TEXT, buildInfoString(context, breadBox, accountManager))
        }
        try {
            context.startActivity(Intent.createChooser(emailIntent, context.getString(R.string.Receive_share)))
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(context, NO_EMAIL_APP_ERROR_MESSAGE, Toast.LENGTH_LONG).show()
        }
    }
}
