/**
 * BreadWallet
 *
 * Created by Ahsan Butt <ahsan.butt@breadwallet.com> on 8/1/19.
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
package com.breadwallet.ui.navigation

import android.content.Intent
import com.bluelinelabs.conductor.Controller
import com.bluelinelabs.conductor.ControllerChangeHandler
import com.bluelinelabs.conductor.Router
import com.bluelinelabs.conductor.RouterTransaction
import com.bluelinelabs.conductor.changehandler.FadeChangeHandler
import com.bluelinelabs.conductor.changehandler.HorizontalChangeHandler
import com.breadwallet.R
import com.breadwallet.legacy.presenter.settings.NotificationSettingsController
import com.breadwallet.ui.settings.analytics.ShareDataController
import com.breadwallet.tools.animation.UiUtils
import com.breadwallet.tools.util.BRConstants
import com.breadwallet.tools.util.EventUtils
import com.breadwallet.tools.util.Link
import com.breadwallet.tools.util.asLink
import com.breadwallet.ui.MainActivity
import com.breadwallet.ui.settings.about.AboutController
import com.breadwallet.ui.addwallets.AddWalletsController
import com.breadwallet.ui.controllers.AlertDialogController
import com.breadwallet.ui.controllers.SignalController
import com.breadwallet.ui.home.HomeController
import com.breadwallet.ui.importwallet.ImportController
import com.breadwallet.ui.login.LoginController
import com.breadwallet.ui.notification.InAppNotificationActivity
import com.breadwallet.ui.onboarding.OnBoardingController
import com.breadwallet.ui.pin.InputPinController
import com.breadwallet.ui.provekey.PaperKeyProveController
import com.breadwallet.ui.receive.ReceiveController
import com.breadwallet.ui.scanner.ScannerController
import com.breadwallet.ui.send.SendSheetController
import com.breadwallet.ui.settings.SettingsController
import com.breadwallet.ui.settings.currency.DisplayCurrencyController
import com.breadwallet.ui.settings.fastsync.FastSyncController
import com.breadwallet.ui.settings.fingerprint.FingerprintSettingsController
import com.breadwallet.ui.settings.nodeselector.NodeSelectorController
import com.breadwallet.ui.settings.segwit.EnableSegWitController
import com.breadwallet.ui.settings.segwit.LegacyAddressController
import com.breadwallet.ui.settings.wipewallet.WipeWalletController
import com.breadwallet.ui.showkey.ShowPaperKeyController
import com.breadwallet.ui.sync.SyncBlockchainController
import com.breadwallet.ui.txdetails.TxDetailsController
import com.breadwallet.ui.wallet.BrdWalletController
import com.breadwallet.ui.wallet.WalletController
import com.breadwallet.ui.web.WebController
import com.breadwallet.ui.writedownkey.WriteDownKeyController
import com.breadwallet.util.isBrd
import com.platform.HTTPServer
import com.platform.util.AppReviewPromptManager
import com.spotify.mobius.Connection
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

private const val BITCOIN_CURRENCY_CODE = "BTC"
private const val BITCOIN_CASH_CURRENCY_CODE = "BCH"

@Suppress("TooManyFunctions")
class RouterNavigationEffectHandler(
    private val router: Router
) : Connection<NavigationEffect>,
    NavigationEffectHandlerSpec {

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun accept(value: NavigationEffect) {
        scope.launch { patch(value) }
    }

    override fun dispose() {
        scope.cancel()
    }

    fun Controller.asTransaction(
        popChangeHandler: ControllerChangeHandler? = FadeChangeHandler(),
        pushChangeHandler: ControllerChangeHandler? = FadeChangeHandler()
    ) = RouterTransaction.with(this)
        .popChangeHandler(popChangeHandler)
        .pushChangeHandler(pushChangeHandler)

    override fun goToWallet(effect: NavigationEffect.GoToWallet) {
        val walletController = when {
            effect.currencyCode.isBrd() -> BrdWalletController()
            else -> WalletController(effect.currencyCode)
        }
        router.pushController(
            RouterTransaction.with(walletController)
                .popChangeHandler(HorizontalChangeHandler())
                .pushChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goBack() {
        if (!router.handleBack()) {
            router.activity?.onBackPressed()
        }
    }

    override fun goToBrdRewards() {
        val rewardsUrl = HTTPServer.getPlatformUrl(HTTPServer.URL_REWARDS)
        router.pushController(RouterTransaction.with(WebController(rewardsUrl)))
    }

    override fun goToReview() {
        EventUtils.pushEvent(EventUtils.EVENT_REVIEW_PROMPT_GOOGLE_PLAY_TRIGGERED)
        AppReviewPromptManager.openGooglePlay(checkNotNull(router.activity))
    }

    override fun goToBuy() {
        val url = String.format(
            BRConstants.CURRENCY_PARAMETER_STRING_FORMAT,
            HTTPServer.getPlatformUrl(HTTPServer.URL_BUY),
            BITCOIN_CURRENCY_CODE
        )
        router.pushController(WebController(url).asTransaction())
    }

    override fun goToTrade() {
        val url = HTTPServer.getPlatformUrl(HTTPServer.URL_TRADE)
        router.pushController(WebController(url).asTransaction())
    }

    override fun goToMenu(effect: NavigationEffect.GoToMenu) {
        router.pushController(
            RouterTransaction.with(SettingsController(effect.settingsOption))
                .popChangeHandler(HorizontalChangeHandler())
                .pushChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToAddWallet() {
        router.pushController(
            RouterTransaction.with(AddWalletsController())
                .popChangeHandler(HorizontalChangeHandler())
                .pushChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToSend(effect: NavigationEffect.GoToSend) {
        val controller = when {
            effect.cryptoRequest != null -> SendSheetController(effect.cryptoRequest)
            else -> SendSheetController(effect.currencyId)
        }
        router.pushController(RouterTransaction.with(controller))
    }

    override fun goToReceive(effect: NavigationEffect.GoToReceive) {
        val controller = ReceiveController(effect.currencyCode)
        router.pushController(RouterTransaction.with(controller))
    }

    override fun goToTransaction(effect: NavigationEffect.GoToTransaction) {
        val controller = TxDetailsController(effect.currencyId, effect.txHash)
        router.pushController(RouterTransaction.with(controller))
    }

    override fun goToDeepLink(effect: NavigationEffect.GoToDeepLink) {
        val link = checkNotNull(effect.url.asLink()) {
            "Invalid deep link provided"
        }
        when (link) {
            is Link.CryptoRequestUrl -> {
                val sendController = SendSheetController(link).asTransaction()
                router.pushWithStackIfEmpty(sendController) {
                    listOf(
                        HomeController().asTransaction(),
                        WalletController(link.currencyCode).asTransaction(
                            popChangeHandler = HorizontalChangeHandler(),
                            pushChangeHandler = HorizontalChangeHandler()
                        ),
                        sendController
                    )
                }
            }
            is Link.BreadUrl.ScanQR -> {
                val controller = ScannerController().asTransaction()
                router.pushWithStackIfEmpty(controller) {
                    listOf(
                        HomeController().asTransaction(),
                        controller
                    )
                }
            }
            is Link.ImportWallet -> {
                val controller = ImportController().asTransaction()
                router.pushWithStackIfEmpty(controller) {
                    listOf(
                        HomeController().asTransaction(),
                        controller
                    )
                }
            }
            else -> {
                Intent(router.activity, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    .putExtra(MainActivity.EXTRA_DATA, effect.url)
                    .run(router.activity!!::startActivity)
            }
        }
    }

    override fun goToInAppMessage(effect: NavigationEffect.GoToInAppMessage) {
        InAppNotificationActivity.start(checkNotNull(router.activity), effect.inAppMessage)
    }

    override fun goToFaq(effect: NavigationEffect.GoToFaq) {
        router.pushController(
            RouterTransaction.with(WebController(effect.asSupportUrl()))
        )
    }

    override fun goToSetPin(effect: NavigationEffect.GoToSetPin) {
        val transaction = RouterTransaction.with(
            InputPinController(
                onComplete = effect.onComplete,
                pinUpdate = !effect.onboarding,
                skipWriteDown = effect.skipWriteDownKey
            )
        ).pushChangeHandler(HorizontalChangeHandler())
            .popChangeHandler(HorizontalChangeHandler())
        if (effect.onboarding) {
            router.setBackstack(listOf(transaction), HorizontalChangeHandler())
        } else {
            router.pushController(transaction)
        }
    }

    override fun goToHome() {
        router.setBackstack(
            listOf(RouterTransaction.with(HomeController())), HorizontalChangeHandler()
        )
    }

    override fun goToLogin() {
        router.pushController(
            RouterTransaction.with(LoginController())
                .popChangeHandler(HorizontalChangeHandler())
                .pushChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToErrorDialog(effect: NavigationEffect.GoToErrorDialog) {
        val res = checkNotNull(router.activity).resources
        router.pushController(
            RouterTransaction.with(AlertDialogController(
                effect.message,
                effect.title,
                negativeText = res.getString(R.string.AccessibilityLabels_close)
            ))
        )
    }

    override fun goToDisabledScreen() {
        UiUtils.showWalletDisabled(checkNotNull(router.activity))
    }

    override fun goToQrScan() {
        val controller = ScannerController()
        controller.targetController = router.backstack.lastOrNull()?.controller()
        router.pushController(
            RouterTransaction.with(controller)
                .pushChangeHandler(FadeChangeHandler())
                .popChangeHandler(FadeChangeHandler())
        )
    }

    override fun goToWriteDownKey(effect: NavigationEffect.GoToWriteDownKey) {
        router.pushController(
            RouterTransaction.with(WriteDownKeyController(effect.onComplete))
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToPaperKey(effect: NavigationEffect.GoToPaperKey) {
        router.pushController(
            RouterTransaction.with(ShowPaperKeyController(effect.phrase, effect.onComplete))
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToPaperKeyProve(effect: NavigationEffect.GoToPaperKeyProve) {
        router.pushController(
            RouterTransaction.with(PaperKeyProveController(effect.phrase, effect.onComplete))
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToGooglePlay() {
        AppReviewPromptManager.openGooglePlay(checkNotNull(router.activity))
    }

    override fun goToAbout() {
        router.pushController(
            AboutController().asTransaction(
                HorizontalChangeHandler(),
                HorizontalChangeHandler()
            )
        )
    }

    override fun goToDisplayCurrency() {
        router.pushController(
            RouterTransaction.with(DisplayCurrencyController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToNotificationsSettings() {
        router.pushController(
            NotificationSettingsController().asTransaction(
                HorizontalChangeHandler(),
                HorizontalChangeHandler()
            )
        )
    }

    override fun goToShareData() {
        router.pushController(
            ShareDataController().asTransaction(
                HorizontalChangeHandler(),
                HorizontalChangeHandler()
            )
        )
    }

    override fun goToFingerprintAuth() {
        router.pushController(
            RouterTransaction.with(FingerprintSettingsController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToWipeWallet() {
        router.pushController(
            RouterTransaction.with(WipeWalletController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToOnboarding() {
        router.pushController(
            RouterTransaction.with(OnBoardingController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToImportWallet() {
        router.pushController(
            ImportController().asTransaction(
                HorizontalChangeHandler(),
                HorizontalChangeHandler()
            )
        )
    }

    override fun goToSyncBlockchain(effect: NavigationEffect.GoToSyncBlockchain) {
        router.pushController(
            RouterTransaction.with(SyncBlockchainController(effect.currencyCode))
                .popChangeHandler(HorizontalChangeHandler())
                .pushChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToBitcoinNodeSelector() {
        router.pushController(
            RouterTransaction.with(NodeSelectorController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToEnableSegWit() {
        router.pushController(
            RouterTransaction.with(EnableSegWitController())
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToLegacyAddress() {
        router.pushController(
            RouterTransaction.with(LegacyAddressController())
        )
    }

    override fun goToFastSync(effect: NavigationEffect.GoToFastSync) {
        router.pushController(
            RouterTransaction.with(FastSyncController(effect.currencyCode))
                .pushChangeHandler(HorizontalChangeHandler())
                .popChangeHandler(HorizontalChangeHandler())
        )
    }

    override fun goToTransactionComplete() {
        val res = checkNotNull(router.activity).resources
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

    private inline fun Router.pushWithStackIfEmpty(
        topTransaction: RouterTransaction,
        createStack: () -> List<RouterTransaction>
    ) {
        if (backstackSize <= 1) {
            setBackstack(createStack(), FadeChangeHandler())
        } else {
            pushController(topTransaction)
        }
    }
}
