package com.breadwallet.ui.send

import android.content.Context
import com.bluelinelabs.conductor.Router
import com.bluelinelabs.conductor.RouterTransaction
import com.breadwallet.R
import com.breadwallet.breadbox.BreadBox
import com.breadwallet.breadbox.addressFor
import com.breadwallet.breadbox.estimateFee
import com.breadwallet.breadbox.formatCryptoForUi
import com.breadwallet.breadbox.toBigDecimal
import com.breadwallet.crypto.Amount
import com.breadwallet.crypto.TransferFeeBasis
import com.breadwallet.crypto.errors.FeeEstimationError
import com.breadwallet.ext.bindConsumerIn
import com.breadwallet.legacy.presenter.entities.CryptoRequest
import com.breadwallet.logger.logError
import com.breadwallet.ui.controllers.AlertDialogController
import com.breadwallet.ui.controllers.SignalController
import com.breadwallet.repository.RatesRepository
import com.breadwallet.tools.manager.BRClipboardManager
import com.spotify.mobius.Connection
import com.spotify.mobius.functions.Consumer
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.channels.BroadcastChannel
import kotlinx.coroutines.channels.Channel.Factory.BUFFERED
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.math.BigDecimal
import kotlin.math.absoluteValue

@Suppress("TooManyFunctions")
@UseExperimental(ExperimentalCoroutinesApi::class, FlowPreview::class)
class SendSheetEffectHandler(
    private val output: Consumer<SendSheetEvent>,
    private val context: Context,
    private val breadBox: BreadBox,
    private val router: Router
) : Connection<SendSheetEffect>, CoroutineScope {

    companion object {
        private const val RATE_UPDATE_MS = 60_000L
    }

    override val coroutineContext =
        SupervisorJob() + Dispatchers.Default +
            CoroutineExceptionHandler { _, throwable ->
                logError("Error in coroutine", throwable)
            }

    private val feeEstimateChannel = BroadcastChannel<SendSheetEffect.EstimateFee>(BUFFERED)

    init {
        collectFeeEstimates()
    }

    @Suppress("ComplexMethod")
    override fun accept(effect: SendSheetEffect) {
        when (effect) {
            SendSheetEffect.ShowClipboardEmpty -> showClipboardEmpty()
            SendSheetEffect.ShowNoAmountError -> showNoAmountError()
            SendSheetEffect.ShowTransactionComplete -> showTransactionComplete()
            is SendSheetEffect.ShowEthTooLowForTokenFee -> showBalanceTooLowForFee(effect)
            is SendSheetEffect.ShowInvalidClipboardData -> showInvalidClipboardData(effect)
            is SendSheetEffect.ShowInvalidAddress -> showInvalidAddress(effect)
            is SendSheetEffect.EstimateFee -> feeEstimateChannel.offer(effect)
            is SendSheetEffect.LoadExchangeRate -> loadExchangeRate(effect)
            is SendSheetEffect.ParseClipboardData -> parseClipboardData(effect)
        }
    }

    override fun dispose() {
        coroutineContext.cancel()
    }

    private fun showNoAmountError() {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            val controller = AlertDialogController(
                message = res.getString(R.string.Send_noAmount),
                positiveText = res.getString(R.string.Button_ok)
            )
            router.pushController(RouterTransaction.with(controller))
        }
    }

    private fun showBalanceTooLowForFee(effect: SendSheetEffect.ShowEthTooLowForTokenFee) {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            // TODO: Handle user acceptance
            val controller = AlertDialogController(
                dialogId = SendSheetController.DIALOG_NO_ETH_FOR_TOKEN_TRANSFER,
                title = res.getString(R.string.Send_insufficientGasTitle),
                message = res.getString(R.string.Send_insufficientGasMessage)
                    .format(effect.networkFee.formatCryptoForUi(effect.currencyCode)),
                positiveText = res.getString(R.string.Button_continueAction),
                negativeText = res.getString(R.string.Button_cancel)
            )
            router.pushController(RouterTransaction.with(controller))
        }
    }

    private fun showClipboardEmpty() {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            val controller = AlertDialogController(
                message = res.getString(R.string.Send_emptyPasteboard),
                positiveText = res.getString(R.string.AccessibilityLabels_close)
            )
            router.pushController(RouterTransaction.with(controller))
        }
    }

    private fun showInvalidClipboardData(effect: SendSheetEffect.ShowInvalidClipboardData) {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            val controller = AlertDialogController(
                message = res.getString(R.string.Send_invalidAddressOnPasteboard)
                    .format(effect.currencyCode.toUpperCase()),
                positiveText = res.getString(R.string.AccessibilityLabels_close)
            )
            router.pushController(RouterTransaction.with(controller))
        }
    }

    private fun showInvalidAddress(effect: SendSheetEffect.ShowInvalidAddress) {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            val controller = AlertDialogController(
                message = res.getString(R.string.Send_invalidAddressMessage)
                    .format(effect.currencyCode.toUpperCase()),
                title = res.getString(R.string.Send_invalidAddressTitle),
                positiveText = res.getString(R.string.AccessibilityLabels_close)
            )
            router.pushController(RouterTransaction.with(controller))
        }
    }

    private fun showTransactionComplete() {
        launch(Dispatchers.Main) {
            val res = router.activity!!.resources
            router.replaceTopController(
                RouterTransaction.with(
                    SignalController(
                        title = res.getString(R.string.Alerts_sendSuccess),
                        description = res.getString(R.string.Alerts_sendSuccessSubheader),
                        iconResId = R.drawable.ic_check_mark_white
                    )
                )
            )
        }
    }

    private fun collectFeeEstimates() {
        feeEstimateChannel.asFlow()
            .flatMapLatest { effect ->
                breadBox.wallet(effect.currencyCode)
                    .take(1)
                    .map { wallet -> wallet to effect }
            }
            .flatMapLatest { (wallet, effect) ->
                val targetTime = effect.transferSpeed.targetTime
                val fees = wallet.walletManager.network.fees
                val fee = when {
                    fees.size == 1 -> fees.single()
                    else -> fees.minBy {
                        (it.confirmationTimeInMilliseconds.toLong() - targetTime).absoluteValue
                    } ?: wallet.walletManager.defaultNetworkFee
                }

                // TODO: Support user selected unit
                val amount = Amount.create(effect.amount.toDouble(), wallet.unit)
                wallet.estimateFee(effect.address, amount, fee)
            }
            .map<TransferFeeBasis, SendSheetEvent> { data ->
                SendSheetEvent.OnNetworkFeeUpdated(data.fee.toBigDecimal(), data)
            }
            .catch { err ->
                if (err !is FeeEstimationError) throw err
                logError("Failed get fee estimate", err)
                // TODO: emit(SendSheetEvent.OnNetworkFeeError)
            }
            .bindConsumerIn(output, this)
    }

    private fun loadExchangeRate(effect: SendSheetEffect.LoadExchangeRate) {
        launch {
            while (isActive) {
                val rates = RatesRepository.getInstance(context)
                val fiatRate = rates.getFiatForCrypto(BigDecimal.ONE, effect.currencyCode, effect.fiatCode)

                output.accept(SendSheetEvent.OnExchangeRateUpdated(fiatRate))

                // TODO: Display out of date, invalid (0) rate, etc.
                delay(RATE_UPDATE_MS)
            }
        }
    }

    private fun parseClipboardData(effect: SendSheetEffect.ParseClipboardData) {
        launch(Dispatchers.Main) { extractClipboardData(effect) }
    }

    // TODO: This should be a shared effect handler to support the scan qr settings button
    @Suppress("ReturnCount")
    private fun extractClipboardData(effect: SendSheetEffect.ParseClipboardData) {
        val text = BRClipboardManager.getClipboard(context)

        if (text.isNullOrBlank()) {
            output.accept(SendSheetEvent.OnAddressPasted.NoAddress)
            return
        }

        // TODO: Refactor CryptoUriParser CryptoUriParser.parseRequest(activity, text)
        val cryptoRequest: CryptoRequest? = null
        val reqAddress = cryptoRequest?.address ?: text
        val reqCurrencyCode = cryptoRequest?.currencyCode

        if (reqAddress.isNullOrBlank()) {
            output.accept(SendSheetEvent.OnAddressPasted.NoAddress)
            return
        }

        if (!reqCurrencyCode.isNullOrBlank() && reqCurrencyCode != effect.currencyCode) {
            output.accept(SendSheetEvent.OnAddressPasted.InvalidAddress)
            return
        }

        breadBox.wallet(effect.currencyCode)
            .take(1)
            .map { wallet ->
                // TODO: Support receive address validation, requires core interface
                val address = wallet.addressFor(reqAddress)
                if (address == null || wallet.source == address) {
                    SendSheetEvent.OnAddressPasted.InvalidAddress
                } else {
                    SendSheetEvent.OnAddressPasted.ValidAddress(reqAddress)
                }
            }
            .bindConsumerIn(output, this)
    }
}
