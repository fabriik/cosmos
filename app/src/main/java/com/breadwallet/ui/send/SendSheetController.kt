/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 9/25/19.
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

import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.TextView
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import com.bluelinelabs.conductor.RouterTransaction
import com.breadwallet.R
import com.breadwallet.breadbox.TransferSpeed
import com.breadwallet.breadbox.formatCryptoForUi
import com.breadwallet.breadbox.formatFiatForUi
import com.breadwallet.effecthandler.metadata.MetaDataEffectHandler
import com.breadwallet.legacy.presenter.customviews.BRKeyboard
import com.breadwallet.legacy.presenter.entities.CryptoRequest
import com.breadwallet.logger.logError
import com.breadwallet.tools.animation.SlideDetector
import com.breadwallet.tools.animation.UiUtils
import com.breadwallet.tools.manager.BRSharedPrefs
import com.breadwallet.tools.util.BRConstants
import com.breadwallet.tools.util.Link
import com.breadwallet.tools.util.Utils
import com.breadwallet.ui.BaseMobiusController
import com.breadwallet.ui.auth.AuthenticationController
import com.breadwallet.ui.changehandlers.BottomSheetChangeHandler
import com.breadwallet.ui.controllers.AlertDialogController
import com.breadwallet.ui.flowbind.clicks
import com.breadwallet.ui.flowbind.textChanges
import com.breadwallet.ui.scanner.ScannerController
import com.breadwallet.ui.send.SendSheet.E
import com.breadwallet.ui.send.SendSheet.E.OnAmountChange
import com.breadwallet.ui.send.SendSheet.F
import com.breadwallet.ui.send.SendSheet.M
import com.spotify.mobius.Connectable
import kotlinx.android.synthetic.main.controller_send_sheet.*
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.flow.onCompletion
import org.kodein.di.direct
import org.kodein.di.erased.instance
import java.math.BigDecimal
import java.text.DecimalFormat
import java.text.NumberFormat
import java.util.Locale

private const val CURRENCY_CODE = "CURRENCY_CODE"
private const val CRYPTO_REQUEST = "CRYPTO_REQUEST"
private const val CRYPTO_REQUEST_LINK = "CRYPTO_REQUEST_LINK"

/** A BottomSheet for sending crypto from the user's wallet to a specified target. */
@Suppress("TooManyFunctions")
class SendSheetController(args: Bundle? = null) :
    BaseMobiusController<M, E, F>(args),
    AuthenticationController.Listener,
    ConfirmTxController.Listener,
    AlertDialogController.Listener,
    ScannerController.Listener {

    companion object {
        const val DIALOG_NO_ETH_FOR_TOKEN_TRANSFER = "adjust_for_fee"
        const val DIALOG_PAYMENT_ERROR = "payment_error"
    }

    /** An empty [SendSheetController] for [currencyCode]. */
    constructor(currencyCode: String) : this(
        bundleOf(CURRENCY_CODE to currencyCode)
    )

    /** A [SendSheetController] to fulfill the provided [CryptoRequest]. */
    constructor(cryptoRequest: CryptoRequest) : this(
        bundleOf(
            CURRENCY_CODE to cryptoRequest.currencyCode,
            CRYPTO_REQUEST to cryptoRequest
        )
    )

    /** A [SendSheetController] to fulfill the provided [Link.CryptoRequestUrl]. */
    constructor(link: Link.CryptoRequestUrl) : this(
        bundleOf(
            CURRENCY_CODE to link.currencyCode,
            CRYPTO_REQUEST_LINK to link
        )
    )

    init {
        overridePushHandler(BottomSheetChangeHandler())
        overridePopHandler(BottomSheetChangeHandler())
    }

    private val currencyCode = arg<String>(CURRENCY_CODE)
    private val cryptoRequest = argOptional<CryptoRequest>(CRYPTO_REQUEST)
    private val cryptoRequestLink = argOptional<Link.CryptoRequestUrl>(CRYPTO_REQUEST_LINK)

    override val layoutId = R.layout.controller_send_sheet
    override val init = SendSheetInit
    override val update = SendSheetUpdate
    override val defaultModel: M
        get() {
            val fiatCode = BRSharedPrefs.getPreferredFiatIso()
            return cryptoRequest?.asSendSheetModel(fiatCode)
                ?: cryptoRequestLink?.asSendSheetModel(fiatCode)
                ?: M.createDefault(currencyCode, fiatCode)
        }

    override val flowEffectHandler
        get() = SendSheetHandler.create(
            checkNotNull(applicationContext),
            router,
            viewCreatedScope,
            { eventConsumer },
            breadBox = direct.instance(),
            keyStore = direct.instance(),
            apiClient = direct.instance(),
            navEffectHandler = direct.instance(),
            metaDataEffectHandler = Connectable {
                MetaDataEffectHandler(it, direct.instance(), direct.instance())
            }
        )

    override fun onCreateView(view: View) {
        super.onCreateView(view)

        keyboard.setBRButtonBackgroundResId(R.drawable.keyboard_white_button)
        keyboard.setBRKeyboardColor(R.color.white)
        keyboard.setDeleteImage(R.drawable.ic_delete_black)

        showKeyboard(false)

        layoutSignal.layoutTransition = UiUtils.getDefaultTransition()
        layoutSignal.setOnTouchListener(SlideDetector(router, layoutSignal))
    }

    override fun onDestroyView(view: View) {
        layoutSignal.setOnTouchListener(null)
        super.onDestroyView(view)
    }

    override fun onDetach(view: View) {
        super.onDetach(view)
        Utils.hideKeyboard(activity)
    }

    override fun bindView(modelFlow: Flow<M>): Flow<E> {
        return merge(
            keyboard.bindInput(),
            textInputMemo.bindFocusChanged(),
            textInputMemo.bindActionComplete(E.OnSendClicked),
            textInputMemo.clicks().map { E.OnAmountEditDismissed },
            textInputMemo.textChanges().map { E.OnMemoChanged(it) },
            textInputAddress.bindFocusChanged(),
            textInputAddress.clicks().map { E.OnAmountEditDismissed },
            textInputAddress.bindActionComplete(E.OnAmountEditDismissed),
            textInputAddress.textChanges().map { E.OnTargetAddressChanged(it) },
            buttonFaq.clicks().map { E.OnFaqClicked },
            buttonScan.clicks().map { E.OnScanClicked },
            buttonSend.clicks().map { E.OnSendClicked },
            buttonClose.clicks().map { E.OnCloseClicked },
            buttonPaste.clicks().map { E.OnPasteClicked },
            layoutBackground.clicks().map { E.OnCloseClicked },
            textInputAmount.clicks().map { E.OnAmountEditClicked },
            buttonCurrencySelect.clicks().map { E.OnToggleCurrencyClicked },
            buttonRegular.clicks().map { E.OnTransferSpeedChanged(TransferSpeed.REGULAR) },
            buttonEconomy.clicks().map { E.OnTransferSpeedChanged(TransferSpeed.ECONOMY) },
            buttonPriority.clicks().map { E.OnTransferSpeedChanged(TransferSpeed.PRIORITY) }
        )
    }

    private fun EditText.bindActionComplete(output: E) =
        callbackFlow<E> {
            setOnEditorActionListener { _, actionId, event ->
                if (event?.keyCode == KeyEvent.KEYCODE_ENTER
                    || actionId == EditorInfo.IME_ACTION_DONE
                    || actionId == EditorInfo.IME_ACTION_NEXT
                ) {
                    offer(output)
                    Utils.hideKeyboard(activity)
                    true
                } else false
            }
            awaitClose { setOnEditorActionListener(null) }
        }

    private fun EditText.bindFocusChanged() =
        callbackFlow<E> {
            View.OnFocusChangeListener { _, hasFocus ->
                if (hasFocus) {
                    offer(E.OnAmountEditDismissed)
                } else {
                    Utils.hideKeyboard(activity)
                }
            }

            awaitClose { onFocusChangeListener = null }
        }

    private fun BRKeyboard.bindInput() =
        callbackFlow<E> {
            setOnInsertListener { key ->
                when {
                    key.isEmpty() -> offer(OnAmountChange.Delete)
                    key[0] == '.' -> offer(OnAmountChange.AddDecimal)
                    Character.isDigit(key[0]) -> offer(OnAmountChange.AddDigit(key.toInt()))
                    else -> return@setOnInsertListener
                }
            }
            awaitClose { setOnInsertListener(null) }
        }

    @Suppress("ComplexMethod", "LongMethod")
    override fun M.render() {
        val res = checkNotNull(resources)

        ifChanged(M::targetInputError) {
            inputLayoutAddress.isErrorEnabled = targetInputError != null
            inputLayoutAddress.error = when (targetInputError) {
                is M.InputError.Empty ->
                    res.getString(R.string.Send_noAddress)
                is M.InputError.Invalid ->
                    res.getString(R.string.Send_invalidAddressMessage, currencyCode.toUpperCase())
                is M.InputError.ClipboardInvalid ->
                    res.getString(
                        R.string.Send_invalidAddressOnPasteboard,
                        currencyCode.toUpperCase()
                    )
                is M.InputError.ClipboardEmpty ->
                    res.getString(R.string.Send_emptyPasteboard)
                else -> null
            }
        }

        ifChanged(M::amountInputError) {
            inputLayoutAmount.isErrorEnabled = amountInputError != null
            inputLayoutAmount.error = when (amountInputError) {
                is M.InputError.Empty ->
                    res.getString(R.string.Send_noAmount)
                is M.InputError.BalanceTooLow ->
                    res.getString(R.string.Send_insufficientFunds)
                else -> null
            }
        }

        ifChanged(
            M::currencyCode,
            M::fiatCode,
            M::isAmountCrypto
        ) {
            val sendTitle = res.getString(R.string.Send_title)
            val upperCaseCurrencyCode = currencyCode.toUpperCase(Locale.getDefault())
            labelTitle.text = "%s %s".format(sendTitle, upperCaseCurrencyCode)
            buttonCurrencySelect.text = when {
                isAmountCrypto -> upperCaseCurrencyCode
                else -> {
                    val currency = java.util.Currency.getInstance(fiatCode)
                    "$fiatCode (${currency.symbol})".toUpperCase(Locale.getDefault())
                }
            }
        }

        ifChanged(M::isAmountEditVisible, ::showKeyboard)

        ifChanged(
            M::rawAmount,
            M::isAmountCrypto,
            M::fiatCode
        ) {
            val formattedAmount = if (isAmountCrypto || rawAmount.isBlank()) {
                rawAmount
            } else {
                rawAmount.formatFiatForInputUi(fiatCode)
            }
            textInputAmount.setText(formattedAmount)
        }

        ifChanged(
            M::networkFee,
            M::fiatNetworkFee,
            M::feeCurrencyCode,
            M::isAmountCrypto
        ) {
            labelNetworkFee.isVisible = networkFee != BigDecimal.ZERO
            labelNetworkFee.text = res.getString(
                R.string.Send_fee,
                when {
                    isAmountCrypto ->
                        networkFee.formatCryptoForUi(feeCurrencyCode, MAX_DIGITS)
                    else -> fiatNetworkFee.formatFiatForUi(fiatCode)
                }
            )
        }

        ifChanged(
            M::balance,
            M::fiatBalance,
            M::isAmountCrypto
        ) {
            labelBalance.text = res.getString(
                R.string.Send_balance,
                when {
                    isAmountCrypto -> balance.formatCryptoForUi(currencyCode)
                    else -> fiatBalance.formatFiatForUi(fiatCode)
                }
            )
        }

        ifChanged(M::targetAddress) {
            if (textInputAddress.text.toString() != targetAddress) {
                textInputAddress.setText(targetAddress, TextView.BufferType.EDITABLE)
            }
        }

        ifChanged(M::memo) {
            if (textInputMemo.text.toString() != memo) {
                textInputMemo.setText(memo, TextView.BufferType.EDITABLE)
            }
        }

        ifChanged(
            M::showFeeSelect,
            M::transferSpeed
        ) {
            layoutFeeOption.isVisible = showFeeSelect
            setFeeOption(transferSpeed)
        }

        ifChanged(M::transferSpeed, ::setFeeOption)
        ifChanged(M::showFeeSelect) {
            layoutFeeOption.isVisible = showFeeSelect
        }

        ifChanged(M::isConfirmingTx) {
            val isConfirmOnTop = router.backstack.first().controller() is ConfirmTxController
            if (isConfirmingTx && !isConfirmOnTop) {
                val controller = ConfirmTxController(
                    currencyCode,
                    fiatCode,
                    feeCurrencyCode,
                    targetAddress,
                    transferSpeed,
                    amount,
                    fiatAmount,
                    fiatTotalCost,
                    fiatNetworkFee
                )
                controller.targetController = this@SendSheetController
                router.pushController(RouterTransaction.with(controller))
            } else if (!isConfirmingTx && isConfirmOnTop) {
                router.popCurrentController()
            }
        }

        ifChanged(M::isAuthenticating) {
            val isAuthOnTop = router.backstack.first().controller() is AuthenticationController
            if (isAuthenticating && !isAuthOnTop) {
                val authenticationMode = if (isFingerprintAuthEnable) {
                    AuthenticationController.Mode.USER_PREFERRED
                } else {
                    AuthenticationController.Mode.PIN_REQUIRED
                }
                val controller = AuthenticationController(
                    mode = authenticationMode,
                    title = res.getString(R.string.VerifyPin_touchIdMessage),
                    message = res.getString(R.string.VerifyPin_authorize)
                )
                controller.targetController = this@SendSheetController
                router.pushController(RouterTransaction.with(controller))
            } else if (!isAuthenticating && isAuthOnTop) {
                router.popCurrentController()
            }
        }

        ifChanged(M::isBitpayPayment) {
            textInputAddress.isEnabled = !isBitpayPayment
            textInputAmount.isEnabled = !isBitpayPayment
            buttonScan.isVisible = !isBitpayPayment
            buttonPaste.isVisible = !isBitpayPayment
        }

        ifChanged(M::isFetchingPayment, M::isSendingTransaction) {
            loadingView.isVisible = isFetchingPayment || isSendingTransaction
        }
    }

    private fun showKeyboard(show: Boolean) {
        groupAmountSection.isVisible = show
        if (show) {
            Utils.hideKeyboard(activity)
        }
    }

    override fun onLinkScanned(link: Link) {
        if (link is Link.CryptoRequestUrl) {
            E.OnRequestScanned(
                currencyCode = link.currencyCode,
                amount = link.amount,
                targetAddress = link.address
            ).run(eventConsumer::accept)
        }
    }

    override fun onAuthenticationSuccess() {
        eventConsumer.accept(E.OnAuthSuccess)
    }

    override fun onAuthenticationCancelled() {
        eventConsumer.accept(E.OnAuthCancelled)
    }

    override fun onPositiveClicked(dialogId: String, controller: AlertDialogController) {
        when (dialogId) {
            DIALOG_NO_ETH_FOR_TOKEN_TRANSFER -> {
                eventConsumer.accept(E.GoToEthWallet)
            }
        }
    }

    override fun onPositiveClicked(controller: ConfirmTxController) {
        eventConsumer
            .accept(E.ConfirmTx.OnConfirmClicked)
    }

    override fun onNegativeClicked(controller: ConfirmTxController) {
        eventConsumer
            .accept(E.ConfirmTx.OnCancelClicked)
    }

    private fun setFeeOption(feeOption: TransferSpeed) {
        val context = applicationContext!!
        // TODO: Redo using a toggle button and a selector
        when (feeOption) {
            TransferSpeed.REGULAR -> {
                buttonRegular.setTextColor(context.getColor(R.color.white))
                buttonRegular.background = context.getDrawable(R.drawable.b_blue_square)
                buttonEconomy.setTextColor(context.getColor(R.color.dark_blue))
                buttonEconomy.background = context.getDrawable(R.drawable.b_half_left_blue_stroke)
                buttonPriority.setTextColor(context.getColor(R.color.dark_blue))
                buttonPriority.background =
                    context.getDrawable(R.drawable.b_half_right_blue_stroke)
                labelFeeDescription.text = context.getString(R.string.FeeSelector_estimatedDeliver)
                    .format(context.getString(R.string.FeeSelector_regularTime))
                labelFeeWarning.visibility = View.GONE
            }
            TransferSpeed.ECONOMY -> {
                buttonRegular.setTextColor(context.getColor(R.color.dark_blue))
                buttonRegular.background = context.getDrawable(R.drawable.b_blue_square_stroke)
                buttonEconomy.setTextColor(context.getColor(R.color.white))
                buttonEconomy.background = context.getDrawable(R.drawable.b_half_left_blue)
                buttonPriority.setTextColor(context.getColor(R.color.dark_blue))
                buttonPriority.background =
                    context.getDrawable(R.drawable.b_half_right_blue_stroke)
                labelFeeDescription.text = context.getString(R.string.FeeSelector_estimatedDeliver)
                    .format(context.getString(R.string.FeeSelector_economyTime))
                labelFeeWarning.visibility = View.VISIBLE
            }
            TransferSpeed.PRIORITY -> {
                buttonRegular.setTextColor(context.getColor(R.color.dark_blue))
                buttonRegular.background = context.getDrawable(R.drawable.b_blue_square_stroke)
                buttonEconomy.setTextColor(context.getColor(R.color.dark_blue))
                buttonEconomy.background = context.getDrawable(R.drawable.b_half_left_blue_stroke)
                buttonPriority.setTextColor(context.getColor(R.color.white))
                buttonPriority.background = context.getDrawable(R.drawable.b_half_right_blue)
                labelFeeDescription.text =
                    context.getString(R.string.FeeSelector_estimatedDeliver)
                        .format(context.getString(R.string.FeeSelector_priorityTime))
                labelFeeWarning.visibility = View.GONE
            }
        }
    }
}

fun String.formatFiatForInputUi(currencyCode: String): String {
    // Ensure decimal displayed when string has not fraction digits
    val forceSeparator = contains('.')
    // Ensure all fraction digits are displayed, even if they are all zero
    val minFractionDigits = substringAfter('.', "").count()

    val amount = toBigDecimalOrNull()

    val currencyFormat = NumberFormat.getCurrencyInstance(Locale.getDefault()) as DecimalFormat
    val decimalFormatSymbols = currencyFormat.decimalFormatSymbols
    currencyFormat.isGroupingUsed = true
    currencyFormat.roundingMode = BRConstants.ROUNDING_MODE
    currencyFormat.isDecimalSeparatorAlwaysShown = forceSeparator
    try {
        val currency = java.util.Currency.getInstance(currencyCode)
        val symbol = currency.symbol
        decimalFormatSymbols.currencySymbol = symbol
        currencyFormat.decimalFormatSymbols = decimalFormatSymbols
        currencyFormat.negativePrefix = "-$symbol"
        currencyFormat.maximumFractionDigits = MAX_DIGITS
        currencyFormat.minimumFractionDigits = minFractionDigits
    } catch (e: IllegalArgumentException) {
        logError("Illegal Currency code: $currencyCode")
    }

    return currencyFormat.format(amount)
}
