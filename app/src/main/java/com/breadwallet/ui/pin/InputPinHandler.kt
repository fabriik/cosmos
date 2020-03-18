/**
 * BreadWallet
 *
 * Created by Pablo Budelli <pablo.budelli@breadwallet.com> on 9/23/19.
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
package com.breadwallet.ui.pin

import android.content.Context
import com.breadwallet.tools.security.BRKeyStore
import com.breadwallet.ui.pin.InputPin.E
import com.breadwallet.ui.pin.InputPin.F
import com.spotify.mobius.Connection
import com.spotify.mobius.functions.Consumer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class InputPinHandler(
    private val output: Consumer<E>,
    private val context: Context,
    private val errorShake: () -> Unit,
    private val showPinFailed: () -> Unit
) : Connection<F>, CoroutineScope {

    override val coroutineContext = SupervisorJob() + Dispatchers.Default

    override fun accept(effect: F) {
        when (effect) {
            is F.SetupPin -> setupPin(effect)
            is F.ErrorShake -> launch(Dispatchers.Main) { errorShake() }
            is F.CheckIfPinExists -> checkIfPinExists()
        }
    }

    override fun dispose() {
        coroutineContext.cancel()
    }

    private fun setupPin(effect: F.SetupPin) {
        if (BRKeyStore.putPinCode(effect.pin, context)) {
            output.accept(E.OnPinSaved)
        } else {
            launch(Dispatchers.Main) { showPinFailed.invoke() }
            output.accept(E.OnPinSaveFailed)
        }
    }

    private fun checkIfPinExists() {
        output.accept(
            E.OnPinCheck(BRKeyStore.getPinCode(context).isNotEmpty())
        )
    }
}
