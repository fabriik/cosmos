/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 10/10/19.
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
package com.platform.tools

import android.content.Context
import androidx.annotation.VisibleForTesting
import android.util.Log
import com.breadwallet.app.BreadApp
import com.breadwallet.logger.logError

import com.breadwallet.tools.security.BrdUserManager
import com.platform.APIClient
import org.kodein.di.KodeinAware
import org.kodein.di.android.closestKodein
import org.kodein.di.erased.instance

object TokenHolder : KodeinAware {
    private val TAG = TokenHolder::class.java.simpleName
    private var mApiToken: String? = null
    private var mOldApiToken: String? = null
    override val kodein by closestKodein {
        BreadApp.getBreadContext()
    }
    private val userManager: BrdUserManager by instance()

    @Synchronized
    fun retrieveToken(app: Context): String? {
        //If token is not present
        if (mApiToken.isNullOrBlank()) {
            //Check BrdUserManager
            val token = userManager.getToken()
            //Not in the BrdUserManager, update from server.
            if (token.isNullOrEmpty()) {
                fetchNewToken(app)
            } else {
                mApiToken = token
            }
        }
        return mApiToken
    }

    @Synchronized
    fun updateToken(app: Context, expiredToken: String?): String? {
        if (mOldApiToken == null || mOldApiToken != expiredToken) {
            Log.e(TAG, "updateToken: updating the token")
            mOldApiToken = mApiToken
            fetchNewToken(app)
        }
        return mApiToken
    }

    @Synchronized
    fun fetchNewToken(app: Context) {
        mApiToken = APIClient.getInstance(app).token
        logError("fetchNewToken: $mApiToken")
        if (!mApiToken.isNullOrEmpty()) {
            userManager.putToken(mApiToken!!)
        }
    }

    @VisibleForTesting
    @Synchronized
    fun reset() {
        mApiToken = null
        mOldApiToken = null
    }
}
