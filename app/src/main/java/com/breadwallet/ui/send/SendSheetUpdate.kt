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
package com.breadwallet.ui.send

import com.breadwallet.ext.isZero
import com.breadwallet.tools.util.BRConstants
import com.breadwallet.ui.send.SendSheet.E
import com.breadwallet.ui.send.SendSheet.E.OnAddressPasted
import com.breadwallet.ui.send.SendSheet.E.OnAddressPasted.InvalidAddress
import com.breadwallet.ui.send.SendSheet.E.OnAddressPasted.NoAddress
import com.breadwallet.ui.send.SendSheet.E.OnAddressPasted.ValidAddress
import com.breadwallet.ui.send.SendSheet.E.OnAmountChange.AddDecimal
import com.breadwallet.ui.send.SendSheet.E.OnAmountChange.AddDigit
import com.breadwallet.ui.send.SendSheet.E.OnAmountChange.Clear
import com.breadwallet.ui.send.SendSheet.E.OnAmountChange.Delete
import com.breadwallet.ui.send.SendSheet.F
import com.breadwallet.ui.send.SendSheet.M
import com.spotify.mobius.Effects.effects
import com.spotify.mobius.Next
import com.spotify.mobius.Next.dispatch
import com.spotify.mobius.Next.next
import com.spotify.mobius.Next.noChange
import com.spotify.mobius.Update
import java.math.BigDecimal

// TODO: Is this specific to a given currency or just the app?
const val MAX_DIGITS = 8

@Suppress("TooManyFunctions", "ComplexMethod", "LargeClass")
object SendSheetUpdate : Update<M, E, F>, SendSheetUpdateSpec {

    override fun update(model: M, event: E) = patch(model, event)

    override fun onAmountChange(
        model: M,
        event: E.OnAmountChange
    ): Next<M, F> {
        return when (event) {
            AddDecimal -> addDecimal(model)
            Delete -> delete(model)
            Clear -> clear(model)
            is AddDigit -> addDigit(model, event)
        }
    }

    private fun addDecimal(
        model: M
    ): Next<M, F> {
        return when {
            model.rawAmount.contains('.') -> noChange()
            model.rawAmount.isEmpty() -> next(
                model.copy(rawAmount = "0.")
            )
            else -> next(
                model.copy(
                    rawAmount = model.rawAmount + '.'
                )
            )
        }
    }

    private fun delete(
        model: M
    ): Next<M, F> {
        return when {
            model.rawAmount.isEmpty() -> noChange()
            else -> {
                val newRawAmount = model.rawAmount.dropLast(1)
                val newModel = model.withNewRawAmount(newRawAmount)
                when {
                    newModel.amount.isZero() ->
                        next(
                            newModel.copy(
                                fiatNetworkFee = BigDecimal.ZERO,
                                networkFee = BigDecimal.ZERO,
                                transferFeeBasis = null
                            )
                        )
                    else -> {
                        val effects = mutableSetOf<F>()
                        if (newModel.canEstimateFee) {
                            F.EstimateFee(
                                newModel.currencyCode,
                                newModel.targetAddress,
                                newModel.amount,
                                newModel.transferSpeed
                            ).run(effects::add)
                        }
                        next(newModel, effects)
                    }
                }
            }
        }
    }

    private fun addDigit(
        model: M,
        event: AddDigit
    ): Next<M, F> {
        return when {
            model.rawAmount == "0" && event.digit == 0 -> noChange()
            model.rawAmount.split('.').run {
                // Ensure the length of the main or fraction
                // if present are less than MAX_DIGITS
                if (size == 1) first().length == MAX_DIGITS
                else getOrNull(1)?.length == MAX_DIGITS
            } -> noChange()
            else -> {
                val effects = mutableSetOf<F>()
                val newRawAmount = when (model.rawAmount) {
                    "0" -> event.digit.toString()
                    else -> model.rawAmount + event.digit
                }

                val newModel = model.withNewRawAmount(newRawAmount)

                if (newModel.canEstimateFee) {
                    effects.add(
                        F.EstimateFee(
                            newModel.currencyCode,
                            newModel.targetAddress,
                            newModel.amount,
                            newModel.transferSpeed
                        )
                    )
                }
                next(newModel, effects)
            }
        }
    }

    private fun clear(model: M): Next<M, F> {
        return when {
            model.rawAmount.isEmpty() && model.amount.isZero() -> noChange()
            else -> next(
                model.copy(
                    rawAmount = "",
                    fiatAmount = BigDecimal.ZERO,
                    amount = BigDecimal.ZERO,
                    networkFee = BigDecimal.ZERO,
                    fiatNetworkFee = BigDecimal.ZERO,
                    transferFeeBasis = null,
                    amountInputError = null
                )
            )
        }
    }

    @Suppress("ComplexCondition")
    override fun onSendClicked(model: M): Next<M, F> {
        val isBalanceTooLow = model.isTotalCostOverBalance
        val isAmountBlank = model.rawAmount.isBlank() || model.amount.isZero()
        val isTargetBlank = model.targetAddress.isBlank()

        if (isBalanceTooLow || isAmountBlank || isTargetBlank) {
            return next(
                model.copy(
                    amountInputError = when {
                        isAmountBlank -> M.InputError.Empty
                        isBalanceTooLow -> M.InputError.BalanceTooLow
                        else -> null
                    },
                    targetInputError = when {
                        isTargetBlank -> M.InputError.Empty
                        else -> null
                    }
                )
            )
        }
        return when {
            model.isSendingTransaction || model.isConfirmingTx -> noChange()
            model.feeEstimateFailed || model.transferFeeBasis == null -> noChange()
            else -> next(
                model.copy(
                    isConfirmingTx = true,
                    amountInputError = null,
                    targetInputError = null
                )
            )
        }
    }

    override fun onScanClicked(model: M): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> dispatch(setOf(F.Nav.GoToScan))
        }
    }

    override fun onFaqClicked(model: M): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> dispatch(setOf(F.Nav.GoToFaq(model.currencyCode)))
        }
    }

    override fun onCloseClicked(model: M): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> dispatch(setOf(F.Nav.CloseSheet))
        }
    }

    override fun onPasteClicked(model: M): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> dispatch(
                setOf(
                    F.ParseClipboardData(model.currencyCode)
                )
            )
        }
    }

    override fun onToggleCurrencyClicked(model: M): Next<M, F> {
        val isAmountCrypto = !model.isAmountCrypto
        val newModel = model.copy(
            isAmountCrypto = isAmountCrypto,
            transferFeeBasis = null,
            rawAmount = when {
                model.amount.isZero() -> model.rawAmount
                else -> when {
                    isAmountCrypto -> model.amount.setScale(MAX_DIGITS, BRConstants.ROUNDING_MODE)
                    else -> model.fiatAmount.setScale(2, BRConstants.ROUNDING_MODE)
                }.toPlainString()
                    .dropLastWhile { it == '0' }
                    .removeSuffix(".")
            }
        )

        return when {
            newModel.canEstimateFee -> next(
                newModel,
                setOf(
                    F.EstimateFee(
                        newModel.currencyCode,
                        newModel.targetAddress,
                        newModel.amount,
                        newModel.transferSpeed
                    )
                )
            )
            else -> next(newModel)
        }
    }

    override fun onBalanceUpdated(
        model: M,
        event: E.OnBalanceUpdated
    ): Next<M, F> {
        val isTotalCostOverBalance = model.totalCost > event.balance
        return next(
            model.copy(
                balance = event.balance,
                fiatBalance = event.fiatBalance,
                isTotalCostOverBalance = isTotalCostOverBalance,
                amountInputError = if (isTotalCostOverBalance) {
                    M.InputError.BalanceTooLow
                } else null,
                networkFee = if (isTotalCostOverBalance) {
                    BigDecimal.ZERO
                } else model.networkFee,
                fiatNetworkFee = if (isTotalCostOverBalance) {
                    BigDecimal.ZERO
                } else model.fiatNetworkFee,
                transferFeeBasis = if (isTotalCostOverBalance) {
                    null
                } else model.transferFeeBasis
            )
        )
    }

    override fun onNetworkFeeUpdated(
        model: M,
        event: E.OnNetworkFeeUpdated
    ): Next<M, F> {
        val isTotalCostOverBalance = model.amount + event.networkFee > model.balance
        return when {
            model.amount != event.amount -> noChange()
            model.targetAddress != event.targetAddress -> noChange()
            else -> next(
                model.copy(
                    networkFee = event.networkFee,
                    fiatNetworkFee = event.networkFee * model.fiatPricePerFeeUnit,
                    transferFeeBasis = event.transferFeeBasis,
                    feeEstimateFailed = false,
                    isTotalCostOverBalance = isTotalCostOverBalance,
                    amountInputError = if (isTotalCostOverBalance) {
                        M.InputError.BalanceTooLow
                    } else null
                )
            )
        }
    }

    override fun onNetworkFeeError(
        model: M
    ): Next<M, F> {
        return next(
            model.copy(
                feeEstimateFailed = true
            )
        )
    }

    override fun onTransferSpeedChanged(
        model: M,
        event: E.OnTransferSpeedChanged
    ): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            model.canEstimateFee -> next(
                model.copy(
                    transferSpeed = event.transferSpeed
                ),
                setOf(
                    F.EstimateFee(
                        model.currencyCode,
                        model.targetAddress,
                        model.amount,
                        event.transferSpeed
                    )
                )
            )
            else -> next(
                model.copy(transferSpeed = event.transferSpeed)
            )
        }
    }

    override fun onTargetAddressChanged(
        model: M,
        event: E.OnTargetAddressChanged
    ): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            model.targetAddress == event.toAddress -> noChange()
            else -> {
                val effects = mutableSetOf<F>()
                val newModel = model.copy(
                    targetAddress = event.toAddress,
                    targetInputError = null
                )

                if (newModel.canEstimateFee) {
                    effects.add(
                        F.EstimateFee(
                            newModel.currencyCode,
                            newModel.targetAddress,
                            newModel.amount,
                            newModel.transferSpeed
                        )
                    )
                }

                next(newModel, effects)
            }
        }
    }

    override fun onMemoChanged(
        model: M,
        event: E.OnMemoChanged
    ): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> next(
                model.copy(
                    memo = event.memo
                )
            )
        }
    }

    override fun onAmountEditClicked(model: M): Next<M, F> {
        return when {
            model.isConfirmingTx -> noChange()
            else -> next(
                model.copy(
                    isAmountEditVisible = !model.isAmountEditVisible
                )
            )
        }
    }

    override fun onAmountEditDismissed(model: M): Next<M, F> {
        return when {
            model.isAmountEditVisible -> next(
                model.copy(
                    isAmountEditVisible = false
                )
            )
            else -> noChange()
        }
    }

    override fun onAddressPasted(
        model: M,
        event: OnAddressPasted
    ): Next<M, F> {
        val effects = mutableSetOf<F>()
        return when {
            model.isConfirmingTx -> noChange()
            else -> when (event) {
                is ValidAddress -> {
                    if (model.canEstimateFee) {
                        F.EstimateFee(
                            model.currencyCode,
                            event.address,
                            model.amount,
                            model.transferSpeed
                        ).run(effects::add)
                    }

                    next(
                        model.copy(
                            targetAddress = event.address,
                            targetInputError = null
                        ),
                        effects
                    )
                }
                is InvalidAddress -> next(
                    model.copy(
                        targetInputError = M.InputError.ClipboardInvalid
                    )
                )
                is NoAddress -> next(
                    model.copy(
                        targetInputError = M.InputError.ClipboardEmpty
                    )
                )
            }
        }
    }

    override fun confirmTx(
        model: M,
        event: E.ConfirmTx
    ): Next<M, F> {
        return when {
            !model.isConfirmingTx -> noChange()
            else -> when (event) {
                E.ConfirmTx.OnConfirmClicked ->
                    next(
                        model.copy(
                            isConfirmingTx = false,
                            isAuthenticating = true
                        )
                    )
                E.ConfirmTx.OnCancelClicked ->
                    next(model.copy(isConfirmingTx = false))
            }
        }
    }

    override fun onExchangeRateUpdated(
        model: M,
        event: E.OnExchangeRateUpdated
    ): Next<M, F> {
        val pricePerUnit = event.fiatPricePerUnit
        val newAmount: BigDecimal
        val newFiatAmount: BigDecimal

        if (model.isAmountCrypto) {
            newAmount = model.amount
            newFiatAmount = if (pricePerUnit > BigDecimal.ZERO) {
                (newAmount * pricePerUnit).setScale(2, BRConstants.ROUNDING_MODE)
            } else {
                model.fiatAmount
            }
        } else {
            newFiatAmount = model.fiatAmount
            newAmount = if (pricePerUnit > BigDecimal.ZERO) {
                newFiatAmount.divide(pricePerUnit, BRConstants.ROUNDING_MODE)
            } else {
                model.amount
            }
        }

        return next(
            model.copy(
                fiatPricePerUnit = pricePerUnit,
                fiatPricePerFeeUnit = event.fiatPricePerFeeUnit,
                feeCurrencyCode = event.feeCurrencyCode,
                amount = newAmount,
                fiatAmount = newFiatAmount,
                fiatNetworkFee = if (pricePerUnit > BigDecimal.ZERO) {
                    (model.networkFee * pricePerUnit).setScale(2, BRConstants.ROUNDING_MODE)
                } else {
                    model.fiatNetworkFee
                }
            )
        )
    }

    override fun onSendComplete(
        model: M,
        event: E.OnSendComplete
    ): Next<M, F> {
        return when {
            model.isSendingTransaction -> {
                val effects = mutableSetOf<F>(
                    F.Nav.GoToTransactionComplete
                )
                if (model.isBitpayPayment) {
                    effects.add(
                        F.PaymentProtocol.PostPayment(
                            model.paymentProtocolRequest!!,
                            event.transfer
                        )
                    )
                }
                if (!model.memo.isNullOrBlank()) {
                    F.AddTransactionMetaData(
                        event.transfer,
                        model.memo,
                        model.fiatCode,
                        model.fiatPricePerUnit
                    ).run(effects::add)
                }
                dispatch(effects)
            }
            else -> noChange()
        }
    }

    override fun onAuthSuccess(
        model: M
    ): Next<M, F> {
        val effects = setOf(
            when {
                model.isBitpayPayment ->
                    F.PaymentProtocol.ContinueWitPayment(
                        model.paymentProtocolRequest!!,
                        transferFeeBasis = checkNotNull(model.transferFeeBasis)
                    )
                else ->
                    F.SendTransaction(
                        currencyCode = model.currencyCode,
                        address = model.targetAddress,
                        amount = model.amount,
                        transferFeeBasis = checkNotNull(model.transferFeeBasis)
                    )
            }
        )
        return when {
            model.isAuthenticating -> next(
                model.copy(
                    isAuthenticating = false,
                    isSendingTransaction = true
                ),
                effects
            )
            else -> noChange()
        }
    }

    override fun onAuthCancelled(
        model: M
    ): Next<M, F> {
        return when {
            model.isAuthenticating -> next(
                model.copy(
                    isAuthenticating = false
                )
            )
            else -> noChange()
        }
    }

    override fun onSendFailed(
        model: M
    ): Next<M, F> {
        return when {
            model.isSendingTransaction ->
                next(
                    model.copy(
                        isSendingTransaction = false
                    )
                )// TODO: Display error (not "something went wrong")
            else -> noChange()
        }
    }

    override fun goToEthWallet(model: M): Next<M, F> {
        return when {
            model.isSendingTransaction || model.isConfirmingTx -> noChange()
            else -> dispatch(setOf(F.Nav.GoToEthWallet))
        }
    }

    override fun onAddressValidated(
        model: M,
        event: E.OnAddressValidated
    ): Next<M, F> {
        if (model.targetAddress != event.address) return noChange()

        val effects = mutableSetOf<F>()
        val newModel = model.copy(
            targetInputError = if (event.isValid) null
            else M.InputError.Invalid
        )

        if (newModel.canEstimateFee) {
            effects.add(
                F.EstimateFee(
                    currencyCode = newModel.currencyCode,
                    address = newModel.targetAddress,
                    amount = newModel.amount,
                    transferSpeed = newModel.transferSpeed
                )
            )
        }

        return next(newModel, effects)
    }

    override fun onAuthenticationSettingsUpdated(
        model: M,
        event: E.OnAuthenticationSettingsUpdated
    ): Next<M, F> {
        return next(model.copy(isFingerprintAuthEnable = event.isFingerprintEnable))
    }

    override fun onRequestScanned(
        model: M,
        event: E.OnRequestScanned
    ): Next<M, F> {
        if (
            !event.currencyCode.equals(model.feeCurrencyCode, true) &&
            !event.currencyCode.equals(model.currencyCode, true)
        ) {
            return noChange()
        }

        val targetAddress = event.targetAddress ?: ""
        val amount = event.amount ?: model.amount
        val rawAmount = event.amount?.stripTrailingZeros()?.toPlainString() ?: model.rawAmount

        val effects = mutableSetOf<F>()

        if (!event.targetAddress.isNullOrBlank() && !amount.isZero()) {
            effects.add(
                F.EstimateFee(
                    model.currencyCode,
                    targetAddress,
                    amount,
                    model.transferSpeed
                )
            )
        }

        return next(
            model.copy(
                isAmountCrypto = true,
                targetAddress = targetAddress,
                amount = amount,
                rawAmount = rawAmount,
                fiatAmount = if (model.fiatPricePerUnit > BigDecimal.ZERO) {
                    (amount * model.fiatPricePerUnit).setScale(2, BRConstants.ROUNDING_MODE)
                } else {
                    model.fiatAmount
                }
            ),
            effects
        )
    }

    override fun paymentProtocol(
        model: M,
        event: E.PaymentProtocol
    ): Next<M, F> {
        return when (event) {
            is E.PaymentProtocol.OnPaymentLoaded -> {
                val paymentRequest = event.paymentRequest
                val amount = event.cryptoAmount
                val newModel = model.copy(
                    targetAddress = paymentRequest.primaryTarget.get().toString(),
                    memo = paymentRequest.memo.get(),
                    amount = amount,
                    paymentProtocolRequest = paymentRequest,
                    fiatAmount = if (model.fiatPricePerUnit > BigDecimal.ZERO) {
                        (amount * model.fiatPricePerUnit).setScale(2, BRConstants.ROUNDING_MODE)
                    } else {
                        model.fiatAmount
                    },
                    rawAmount = amount.setScale(
                        MAX_DIGITS,
                        BRConstants.ROUNDING_MODE
                    ).toPlainString().dropLastWhile { it == '0' },
                    isFetchingPayment = false
                )
                next(
                    newModel,
                    effects(
                        F.EstimateFee(
                            model.currencyCode,
                            newModel.targetAddress,
                            amount,
                            model.transferSpeed
                        )
                    )
                )
            }
            is E.PaymentProtocol.OnLoadFailed -> {
                next(
                    model.copy(isFetchingPayment = false),
                    effects(F.ShowErrorDialog(event.message))
                )
            }
            else -> noChange()
        }
    }
}
