/**
 * BreadWallet
 *
 * Created by Ahsan Butt <ahsan.butt@breadwallet.com> on 10/24/19.
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
package com.breadwallet.effecthandler.metadata

import com.breadwallet.crypto.Transfer
import com.breadwallet.crypto.WalletManagerMode
import java.math.BigDecimal

sealed class MetaDataEffect {

    object RecoverMetaData : MetaDataEffect()

    data class LoadTransactionMetaData(val transactionHashes: List<String>) : MetaDataEffect() {
        constructor(transactionHash: String) : this(listOf(transactionHash))
    }

    data class AddTransactionMetaData(
        val transaction: Transfer,
        val comment: String,
        val fiatCurrencyCode: String,
        val fiatPricePerUnit: BigDecimal
    ) : MetaDataEffect()

    data class UpdateTransactionComment(
        val transactionHash: String,
        val comment: String
    ) : MetaDataEffect()

    data class UpdateWalletMode(
        val currencyId: String,
        val mode: WalletManagerMode
    ) : MetaDataEffect()

    object LoadWalletModes : MetaDataEffect()
}
