/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 8/13/19.
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
package com.breadwallet.ui.scanner

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import com.breadwallet.R
import com.breadwallet.logger.logDebug
import com.breadwallet.logger.logError
import com.breadwallet.tools.qrcode.scannedText
import com.breadwallet.tools.util.BRConstants
import com.breadwallet.tools.util.Link
import com.breadwallet.tools.util.asLink
import com.breadwallet.ui.BaseController
import com.breadwallet.ui.MainActivity
import kotlinx.android.synthetic.main.controller_scanner.*
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.mapLatest
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.flow.transformLatest

private const val CAMERA_UI_UPDATE_MS = 100L

@UseExperimental(ExperimentalCoroutinesApi::class)
class ScannerController(
    args: Bundle? = null
) : BaseController(args) {

    interface Listener {
        fun onLinkScanned(link: Link)
    }

    override val layoutId = R.layout.controller_scanner

    override fun onAttach(view: View) {
        super.onAttach(view)
        val context = checkNotNull(applicationContext)

        val cameraPermission = context.checkSelfPermission(Manifest.permission.CAMERA)
        if (cameraPermission == PackageManager.PERMISSION_GRANTED) {
            startScanner()
        } else {
            requestPermissions(
                arrayOf(Manifest.permission.CAMERA),
                BRConstants.CAMERA_REQUEST_ID
            )
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == BRConstants.CAMERA_REQUEST_ID) {
            when (grantResults.single()) {
                PackageManager.PERMISSION_GRANTED -> startScanner()
                PackageManager.PERMISSION_DENIED -> router.popController(this)
            }
        }
    }

    private fun startScanner() {
        qrdecoderview
            .scannedText(true)
            .mapLatest { text -> text to text.asLink() }
            .flowOn(Default)
            .transformLatest { (text, link) ->
                if (link == null) {
                    logError("Found incompatible QR code")
                    showGuideError()
                } else {
                    logDebug("Found compatible QR code")
                    scan_guide.setImageResource(R.drawable.cameraguide)
                    emit(text to link)
                }
            }
            .take(1)
            .onEach { (text, link) ->
                handleValidLink(text, link)
            }
            .flowOn(Main)
            .launchIn(viewAttachScope)
    }

    private fun handleValidLink(text: String, link: Link) {
        // Try calling the targetController to handle the link,
        // if no listener handles it, dispatch to MainActivity.
        val consumed: Unit? = (targetController as? Listener)?.onLinkScanned(link)
        if (consumed == null) {
            Intent(applicationContext, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(MainActivity.EXTRA_DATA, text)
                .run(this::startActivity)
        }
        router.popController(this@ScannerController)
    }

    /** Display an error state for [CAMERA_UI_UPDATE_MS] then reset. */
    private suspend fun showGuideError() {
        scan_guide.setImageResource(R.drawable.cameraguide_red)
        delay(CAMERA_UI_UPDATE_MS)
        scan_guide.setImageResource(R.drawable.cameraguide)
    }
}
