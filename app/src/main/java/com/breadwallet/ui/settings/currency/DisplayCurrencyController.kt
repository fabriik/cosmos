/**
 * BreadWallet
 *
 * Created by Pablo Budelli <pablo.budelli@breadwallet.com> on 1/7/20.
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
package com.breadwallet.ui.settings.currency

import android.support.v7.widget.LinearLayoutManager
import com.breadwallet.R
import com.breadwallet.ui.BaseMobiusController
import com.breadwallet.ui.flowbind.clicks
import com.spotify.mobius.flow.FlowTransformer
import kotlinx.android.synthetic.main.controller_display_currency.*
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import org.kodein.di.direct
import org.kodein.di.erased.instance

@UseExperimental(ExperimentalCoroutinesApi::class, FlowPreview::class)
class DisplayCurrencyController :
    BaseMobiusController<DisplayCurrency.M, DisplayCurrency.E, DisplayCurrency.F>() {

    override val layoutId = R.layout.controller_display_currency

    override val defaultModel = DisplayCurrency.M.createDefault()
    override val init = DisplayCurrencyInit
    override val update = CurrencyUpdate
    override val flowEffectHandler: FlowTransformer<DisplayCurrency.F, DisplayCurrency.E>?
        get() = DisplayCurrencyEffects.createEffectHandler(direct.instance())

    override fun bindView(modelFlow: Flow<DisplayCurrency.M>): Flow<DisplayCurrency.E> {
        currency_list.layoutManager = LinearLayoutManager(checkNotNull(activity))
        return merge(
            back_button.clicks().map { DisplayCurrency.E.OnBackClicked },
            faq_button.clicks().map { DisplayCurrency.E.OnFaqClicked },
            bindCurrencyList(modelFlow)
        )
    }

    private fun bindCurrencyList(
        modelFlow: Flow<DisplayCurrency.M>
    ) = callbackFlow<DisplayCurrency.E> {
        currency_list.adapter = FiatCurrencyAdapter(
            modelFlow
                .map { model -> model.currencies }
                .distinctUntilChanged(),
            modelFlow
                .map { model -> model.selectedCurrency }
                .distinctUntilChanged(),
            sendChannel = channel
        )
        awaitClose { currency_list.adapter = null }
    }
}