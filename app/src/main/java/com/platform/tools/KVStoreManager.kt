/**
 * BreadWallet
 *
 *
 * Created by Mihail Gutan on <mihail></mihail>@breadwallet.com> 6/22/17.
 * Copyright (c) 2017 breadwallet LLC
 *
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.platform.tools

import android.content.Context

import com.breadwallet.tools.manager.BRReportsManager
import com.breadwallet.tools.util.BRCompressor
import com.breadwallet.ui.util.logDebug
import com.breadwallet.ui.util.logError
import com.breadwallet.ui.util.logWarning
import com.platform.APIClient
import com.platform.interfaces.KVStoreProvider
import com.platform.kvstore.CompletionObject
import com.platform.kvstore.RemoteKVStore
import com.platform.kvstore.ReplicatedKVStore
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.channels.BroadcastChannel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.onStart

import org.json.JSONObject

import java.io.IOException

@UseExperimental(ExperimentalCoroutinesApi::class, FlowPreview::class)
@Suppress("TooManyFunctions")
internal class KVStoreManager(
    private val context: Context
) : KVStoreProvider {

    // TODO: Compose with data store interface passed in constructor
    // TODO: Add retry/timeout behaviors?

    private val keyChannelMap = mutableMapOf<String, BroadcastChannel<JSONObject>>().run {
        withDefault { key -> getOrPut(key) { BroadcastChannel(Channel.BUFFERED) } }
    }

    override fun get(key: String): JSONObject? =
        when (val data = getData(context, key)) {
            null -> {
                logError("Data value is null")
                null
            }
            else -> JSONObject(String(data))
        }

    override fun put(key: String, value: JSONObject): Boolean {
        logDebug("put $key -> $value")
        val valueStr = value.toString().toByteArray()

        if (valueStr.isEmpty()) {
            logError("FAILED: result is empty")
            return false
        }
        val completionObject = setData(context, valueStr, key)
        return when (completionObject?.err) {
            null -> {
                keyChannelMap.getValue(key).offer(value)
                true
            }
            else -> {
                logError("Error setting value for key: $key, err: ${completionObject.err}")
                false
            }
        }
    }

    override fun sync(key: String) {
        getReplicatedKvStore(context).syncKey(key)
        get(key)?.let { keyChannelMap.getValue(key).offer(it) }
    }

    override fun syncAll(): Boolean =
        getReplicatedKvStore(context).syncAllKeys()
            .also {
                if (it) {
                    keyChannelMap.keys.forEach { key ->
                        get(key)?.let { value ->
                            keyChannelMap.getValue(key).offer(value)
                        }
                    }
                }
            }

    override fun keyFlow(key: String): Flow<JSONObject> =
        keyChannelMap.getValue(key).asFlow().onStart { get(key)?.let { emit(it) } }

    private fun setData(context: Context, data: ByteArray, key: String?): CompletionObject? =
        try {
            val compressed = BRCompressor.bz2Compress(data)
            val kvStore = getReplicatedKvStore(context)
            val localVer = kvStore.localVersion(key).version
            val removeVer = kvStore.remoteVersion(key)

            kvStore.set(localVer, removeVer, key, compressed, System.currentTimeMillis(), 0)
        } catch (e: IOException) {
            BRReportsManager.reportBug(e)
            null
        }

    private fun getData(context: Context, key: String): ByteArray? {
        val kvStore = getReplicatedKvStore(context)
        val ver = kvStore.localVersion(key).version
        val obj = kvStore.get(key, ver)
        if (obj.kv == null) {
            logWarning("getData: value is null for key: $key")
            return null
        }
        return when (val decompressed = BRCompressor.bz2Extract(obj.kv.value)) {
            null -> {
                logError("getData: decompressed value is null")
                null
            }
            else -> decompressed
        }
    }

    private fun getReplicatedKvStore(context: Context): ReplicatedKVStore {
        val remoteKVStore = RemoteKVStore.getInstance(APIClient.getInstance(context))
        return ReplicatedKVStore.getInstance(context, remoteKVStore)
    }
}
