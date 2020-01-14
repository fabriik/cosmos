/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 1/14/20.
 * Copyright (c) 2020 breadwallet LLC
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
package com.breadwallet.ui.sync

import android.os.Bundle
import androidx.core.os.bundleOf
import com.bluelinelabs.conductor.RouterTransaction
import com.breadwallet.R
import com.breadwallet.ui.BaseMobiusController
import com.breadwallet.ui.controllers.AlertDialogController
import com.breadwallet.ui.flowbind.clicks
import com.breadwallet.ui.sync.SyncBlockchain.E
import com.breadwallet.ui.sync.SyncBlockchain.F
import com.breadwallet.ui.sync.SyncBlockchain.M
import com.breadwallet.util.CurrencyCode
import kotlinx.android.synthetic.main.controller_sync_blockchain.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import org.kodein.di.direct
import org.kodein.di.erased.instance

private const val CURRENCY_CODE = "currency_code"

class SyncBlockchainController(
    args: Bundle
) : BaseMobiusController<M, E, F>(args),
    SyncBlockchain.ViewActions,
    AlertDialogController.Listener {

    constructor(currencyCode: CurrencyCode) : this(
        bundleOf(
            CURRENCY_CODE to currencyCode
        )
    )

    override val layoutId = R.layout.controller_sync_blockchain

    override val defaultModel = M(arg(CURRENCY_CODE))
    override val update = SyncBlockchainUpdate

    override val flowEffectHandler
        get() = SyncBlockchainHandler.create(
            this,
            direct.instance(),
            direct.instance()
        )

    override fun bindView(modelFlow: Flow<M>): Flow<E> {
        return merge(
            faq_button.clicks().map { E.OnFaqClicked },
            button_scan.clicks().map { E.OnSyncClicked }
        )
    }

    override fun onPositiveClicked(dialogId: String, controller: AlertDialogController) {
        eventConsumer.accept(E.OnConfirmSyncClicked)
    }

    override fun showRescanPrompt() {
        val res = checkNotNull(resources)
        val dialog = AlertDialogController(
            res.getString(R.string.ReScan_footer),
            res.getString(R.string.ReScan_alertTitle),
            res.getString(R.string.ReScan_alertAction),
            res.getString(R.string.Button_cancel)
        )
        dialog.targetController = this
        router.pushController(RouterTransaction.with(dialog))
    }
}
