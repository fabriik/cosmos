// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// FIO
  internal static let sendFioToLabel = L10n.tr("Localizable", "Send_fio_toLabel")
  /// Always require passcode
  internal static let touchIdSpendingLimit = L10n.tr("Localizable", "TouchIdSpendingLimit")

  internal enum ATMMapView {
    /// ATM Cash Locations Map
    internal static let title = L10n.tr("Localizable", "ATMMapView.title")
  }

  internal enum About {
    /// Blog
    internal static let blog = L10n.tr("Localizable", "About.blog")
    /// Made by the global Fabriik team.
    /// Version %1$@ Build %2$@
    internal static func footer(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "About.footer", String(describing: p1), String(describing: p2))
    }
    /// Privacy Policy
    internal static let privacy = L10n.tr("Localizable", "About.privacy")
    /// Reddit
    internal static let reddit = L10n.tr("Localizable", "About.reddit")
    /// Terms And Conditions
    internal static let terms = L10n.tr("Localizable", "About.terms")
    /// About
    internal static let title = L10n.tr("Localizable", "About.title")
    /// Twitter
    internal static let twitter = L10n.tr("Localizable", "About.twitter")
    /// Fabriik Rewards ID
    internal static let walletID = L10n.tr("Localizable", "About.walletID")
    internal enum AppName {
      /// Fabriik
      internal static let android = L10n.tr("Localizable", "About.appName.android")
    }
  }

  internal enum AccessibilityLabels {
    /// Close
    internal static let close = L10n.tr("Localizable", "AccessibilityLabels.close")
    /// Support Center
    internal static let faq = L10n.tr("Localizable", "AccessibilityLabels.faq")
  }

  internal enum Account {
    /// Balance
    internal static let balance = L10n.tr("Localizable", "Account.balance")
    /// This token has been delisted. 
    /// 
    /// You may still be able to send these tokens to another platform. For more details, visit our support page.
    internal static let delistedToken = L10n.tr("Localizable", "Account.delistedToken")
    /// %1$@ per %2$@
    internal static func exchangeRate(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "Account.exchangeRate", String(describing: p1), String(describing: p2))
    }
    /// Loading Wallet
    internal static let loadingMessage = L10n.tr("Localizable", "Account.loadingMessage")
  }

  internal enum AccountCreation {
    /// Only create a Hedera account if you intend on storing HBAR in your wallet.
    internal static let body = L10n.tr("Localizable", "AccountCreation.body")
    /// Create Account
    internal static let create = L10n.tr("Localizable", "AccountCreation.create")
    /// Creating Account
    internal static let creating = L10n.tr("Localizable", "AccountCreation.creating")
    /// An error occurred during account creation. Please try again later.
    internal static let error = L10n.tr("Localizable", "AccountCreation.error")
    /// Not Now
    internal static let notNow = L10n.tr("Localizable", "AccountCreation.notNow")
    /// The Request timed out. Please try again later.
    internal static let timeout = L10n.tr("Localizable", "AccountCreation.timeout")
    /// Confirm Account Creation
    internal static let title = L10n.tr("Localizable", "AccountCreation.title")
  }

  internal enum AccountHeader {
    /// My Fabriik
    internal static let defaultWalletName = L10n.tr("Localizable", "AccountHeader.defaultWalletName")
  }

  internal enum Alert {
    /// Error
    internal static let error = L10n.tr("Localizable", "Alert.error")
    /// Insufficient Ethereum Balance
    internal static let ethBalance = L10n.tr("Localizable", "Alert.ethBalance")
    /// No internet connection found. Check your connection and try again.
    internal static let noInternet = L10n.tr("Localizable", "Alert.noInternet")
    /// Something went wrong. Please try again.
    internal static let somethingWentWrong = L10n.tr("Localizable", "Alert.somethingWentWrong")
    /// Request timed out. Check your connection and try again.
    internal static let timedOut = L10n.tr("Localizable", "Alert.timedOut")
    /// Warning
    internal static let warning = L10n.tr("Localizable", "Alert.warning")
    internal enum CustomKeyboard {
      /// It looks like you are using a third-party keyboard, which can record what you type and steal your Recovery Phrase. Please switch to the default Android keyboard for extra protection.
      internal static let android = L10n.tr("Localizable", "Alert.customKeyboard.android")
    }
    internal enum Keystore {
      internal enum Generic {
        /// There is a problem with your Android OS keystore, please contact support@fabriik.com
        internal static let android = L10n.tr("Localizable", "Alert.keystore.generic.android")
      }
      internal enum Invalidated {
        /// Your Fabriik encrypted data was recently invalidated because your Android lock screen was disabled.
        internal static let android = L10n.tr("Localizable", "Alert.keystore.invalidated.android")
        internal enum Uninstall {
          /// We can't proceed because your screen lock settings have been changed (e.g. password was disabled, fingerprints were changed). For security purposes, Android has permanently locked your key store. Therefore, your Fabriik app data must be wiped by uninstalling.
          /// 
          /// Don’t worry, your funds are still secure! Reinstall the app and recover your wallet using your recovery phrase.
          internal static let android = L10n.tr("Localizable", "Alert.keystore.invalidated.uninstall.android")
        }
        internal enum Wipe {
          /// We can't proceed because your screen lock settings have been changed (e.g. password was disabled, fingerprints were changed). For security purposes, Android has permanently locked your key store. Therefore, your Fabriik app data must be wiped.
          /// 
          /// Don’t worry, your funds are still secure! Recover your wallet using your recovery phrase.
          internal static let android = L10n.tr("Localizable", "Alert.keystore.invalidated.wipe.android")
        }
      }
      internal enum Title {
        /// Android Key Store Error
        internal static let android = L10n.tr("Localizable", "Alert.keystore.title.android")
      }
    }
  }

  internal enum Alerts {
    /// Addresses Copied
    internal static let copiedAddressesHeader = L10n.tr("Localizable", "Alerts.copiedAddressesHeader")
    /// All wallet addresses successfully copied.
    internal static let copiedAddressesSubheader = L10n.tr("Localizable", "Alerts.copiedAddressesSubheader")
    /// Recovery Key Set
    internal static let paperKeySet = L10n.tr("Localizable", "Alerts.paperKeySet")
    /// Awesome!
    internal static let paperKeySetSubheader = L10n.tr("Localizable", "Alerts.paperKeySetSubheader")
    /// PIN Set
    internal static let pinSet = L10n.tr("Localizable", "Alerts.pinSet")
    /// Send failed
    internal static let sendFailure = L10n.tr("Localizable", "Alerts.sendFailure")
    /// Send Confirmation
    internal static let sendSuccess = L10n.tr("Localizable", "Alerts.sendSuccess")
    /// Money Sent!
    internal static let sendSuccessSubheader = L10n.tr("Localizable", "Alerts.sendSuccessSubheader")
    internal enum TouchIdSucceeded {
      /// Fingerprint recognized
      internal static let android = L10n.tr("Localizable", "Alerts.touchIdSucceeded.android")
    }
  }

  internal enum Android {
    /// Please enable storage permissions in your device settings: "Settings" > "Apps" > "Fabriik" > "Permissions".
    internal static let allowFileSystemAccess = L10n.tr("Localizable", "Android.allowFileSystemAccess")
    /// We've detected an app that is incompatible with Fabriik running on your device. For security reasons, please disable any screen altering or light filtering apps to proceed.
    internal static let screenAlteringMessage = L10n.tr("Localizable", "Android.screenAlteringMessage")
    /// Screen Altering App Detected
    internal static let screenAlteringTitle = L10n.tr("Localizable", "Android.screenAlteringTitle")
    internal enum Bch {
      internal enum Welcome {
        /// Any BCH in your wallet can be accessed through the home screen.
        internal static let message = L10n.tr("Localizable", "Android.BCH.welcome.message")
      }
    }
  }

  internal enum ApiClient {
    /// JSON Serialization Error
    internal static let jsonError = L10n.tr("Localizable", "ApiClient.jsonError")
    /// Wallet not ready
    internal static let notReady = L10n.tr("Localizable", "ApiClient.notReady")
    /// Unable to retrieve API token
    internal static let tokenError = L10n.tr("Localizable", "ApiClient.tokenError")
  }

  internal enum Bch {
    /// Enter a destination BCH address below. All BCH in your wallet at the time of the fork (%1$@) will be sent.
    internal static func body(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BCH.body", String(describing: p1))
    }
    /// Confirm sending %1$@ to %2$@
    internal static func confirmationMessage(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "BCH.confirmationMessage", String(describing: p1), String(describing: p2))
    }
    /// Confirmation
    internal static let confirmationTitle = L10n.tr("Localizable", "BCH.confirmationTitle")
    /// Your account does not contain any BCH, or you received BCH after the fork.
    internal static let genericError = L10n.tr("Localizable", "BCH.genericError")
    /// Transaction ID copied
    internal static let hashCopiedMessage = L10n.tr("Localizable", "BCH.hashCopiedMessage")
    /// Please enter an address
    internal static let noAddressError = L10n.tr("Localizable", "BCH.noAddressError")
    /// Payment Protocol Requests are not supported for BCH transactions
    internal static let paymentProtocolError = L10n.tr("Localizable", "BCH.paymentProtocolError")
    /// BCH was successfully sent.
    internal static let successMessage = L10n.tr("Localizable", "BCH.successMessage")
    /// Withdraw BCH
    internal static let title = L10n.tr("Localizable", "BCH.title")
    /// BCH Transaction ID
    internal static let txHashHeader = L10n.tr("Localizable", "BCH.txHashHeader")
  }

  internal enum BitID {
    /// Approve
    internal static let approve = L10n.tr("Localizable", "BitID.approve")
    /// %1$@ is requesting authentication using your bitcoin wallet
    internal static func authenticationRequest(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BitID.authenticationRequest", String(describing: p1))
    }
    /// Deny
    internal static let deny = L10n.tr("Localizable", "BitID.deny")
    /// Authentication Error
    internal static let error = L10n.tr("Localizable", "BitID.error")
    /// Please check with the service. You may need to try again.
    internal static let errorMessage = L10n.tr("Localizable", "BitID.errorMessage")
    /// Successfully Authenticated
    internal static let success = L10n.tr("Localizable", "BitID.success")
    /// BitID Authentication Request
    internal static let title = L10n.tr("Localizable", "BitID.title")
  }

  internal enum Button {
    /// Buy
    internal static let buy = L10n.tr("Localizable", "Button.buy")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Button.cancel")
    /// Close
    internal static let close = L10n.tr("Localizable", "Button.close")
    /// Confirm
    internal static let confirm = L10n.tr("Localizable", "Button.confirm")
    /// Continue
    internal static let continueAction = L10n.tr("Localizable", "Button.continueAction")
    /// Dismiss
    internal static let dismiss = L10n.tr("Localizable", "Button.dismiss")
    /// Done
    internal static let done = L10n.tr("Localizable", "Button.done")
    /// Home
    internal static let home = L10n.tr("Localizable", "Button.Home")
    /// Ignore
    internal static let ignore = L10n.tr("Localizable", "Button.ignore")
    /// Map
    internal static let map = L10n.tr("Localizable", "Button.map")
    /// Maybe Later
    internal static let maybeLater = L10n.tr("Localizable", "Button.maybeLater")
    /// Menu
    internal static let menu = L10n.tr("Localizable", "Button.menu")
    /// More info
    internal static let moreInfo = L10n.tr("Localizable", "Button.moreInfo")
    /// No
    internal static let no = L10n.tr("Localizable", "Button.no")
    /// OK
    internal static let ok = L10n.tr("Localizable", "Button.ok")
    /// Open Settings
    internal static let openSettings = L10n.tr("Localizable", "Button.openSettings")
    /// Receive
    internal static let receive = L10n.tr("Localizable", "Button.receive")
    /// Search
    internal static let search = L10n.tr("Localizable", "Button.search")
    /// Sell
    internal static let sell = L10n.tr("Localizable", "Button.sell")
    /// Send
    internal static let send = L10n.tr("Localizable", "Button.send")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "Button.settings")
    /// Set Up
    internal static let setup = L10n.tr("Localizable", "Button.setup")
    /// Skip
    internal static let skip = L10n.tr("Localizable", "Button.skip")
    /// Submit
    internal static let submit = L10n.tr("Localizable", "Button.submit")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "Button.yes")
    internal enum ContactSupport {
      /// Contact Support
      internal static let android = L10n.tr("Localizable", "Button.contactSupport.android")
    }
    internal enum SecuritySettings {
      /// Security Settings
      internal static let android = L10n.tr("Localizable", "Button.securitySettings.android")
    }
    internal enum Uninstall {
      /// Uninstall
      internal static let android = L10n.tr("Localizable", "Button.uninstall.android")
    }
    internal enum Wipe {
      /// Wipe
      internal static let android = L10n.tr("Localizable", "Button.wipe.android")
    }
  }

  internal enum CameraPlugin {
    /// Center your ID in the box
    internal static let centerInstruction = L10n.tr("Localizable", "CameraPlugin.centerInstruction")
  }

  internal enum CashToken {
    /// Please send bitcoin to this address to withdraw at the ATM. Scan QR code or copy and paste to send bitcoin. Note that it may take a few minutes for the transfer to be confirmed.
    internal static let actionInstructions = L10n.tr("Localizable", "CashToken.actionInstructions")
    /// Amount (BTC)
    internal static let amountBTC = L10n.tr("Localizable", "CashToken.amountBTC")
    /// Amount (USD)
    internal static let amountUSD = L10n.tr("Localizable", "CashToken.amountUSD")
    /// Awaiting Funds
    internal static let awaitingFunds = L10n.tr("Localizable", "CashToken.awaitingFunds")
    /// Withdrawl Status
    internal static let label = L10n.tr("Localizable", "CashToken.label")
    /// Location
    internal static let location = L10n.tr("Localizable", "CashToken.location")
    /// Please Verify
    internal static let pleaseVerify = L10n.tr("Localizable", "CashToken.pleaseVerify")
  }

  internal enum CloudBackup {
    /// Backup Erased
    internal static let backupDeleted = L10n.tr("Localizable", "CloudBackup.backupDeleted")
    /// Your iCloud backup has been erased after too many failed PIN attempts. The app will now restart.
    internal static let backupDeletedMessage = L10n.tr("Localizable", "CloudBackup.backupDeletedMessage")
    /// iCloud Backup
    internal static let backupMenuTitle = L10n.tr("Localizable", "CloudBackup.backupMenuTitle")
    /// Create new wallet
    internal static let createButton = L10n.tr("Localizable", "CloudBackup.createButton")
    /// A previously backed up wallet has been detected. Using this backup is recomended. Are you sure you want to proceeed with creating a new wallet?
    internal static let createWarning = L10n.tr("Localizable", "CloudBackup.createWarning")
    /// iCloud Keychain must be turned on for this feature to work.
    internal static let enableBody1 = L10n.tr("Localizable", "CloudBackup.enableBody1")
    /// It should look like the following:
    internal static let enableBody2 = L10n.tr("Localizable", "CloudBackup.enableBody2")
    /// I have turned on iCloud Keychain
    internal static let enableButton = L10n.tr("Localizable", "CloudBackup.enableButton")
    /// Enable Keychain
    internal static let enableTitle = L10n.tr("Localizable", "CloudBackup.enableTitle")
    /// Enter pin to encrypt backup
    internal static let encryptBackupMessage = L10n.tr("Localizable", "CloudBackup.encryptBackupMessage")
    /// Please note, iCloud backup is only as secure as your iCloud account. We still recommend writing down your recovery phrase in the following step and keeping it secure. The recovery phrase is the only way to recover your wallet if you can no longer access iCloud.
    internal static let mainBody = L10n.tr("Localizable", "CloudBackup.mainBody")
    /// iCloud Recovery Backup
    internal static let mainTitle = L10n.tr("Localizable", "CloudBackup.mainTitle")
    /// iCloud Keychain must be turned on in the iOS Settings app for this feature to work
    internal static let mainWarning = L10n.tr("Localizable", "CloudBackup.mainWarning")
    /// Are you sure you want to disable iCloud Backup? This will delete your backup from all devices.
    internal static let mainWarningConfirmation = L10n.tr("Localizable", "CloudBackup.mainWarningConfirmation")
    /// Attempts remaining before erasing backup: %1$@
    internal static func pinAttempts(_ p1: Any) -> String {
      return L10n.tr("Localizable", "CloudBackup.pinAttempts", String(describing: p1))
    }
    /// Restore from Recovery Phrase
    internal static let recoverButton = L10n.tr("Localizable", "CloudBackup.recoverButton")
    /// Enter PIN to unlock iCloud backup
    internal static let recoverHeader = L10n.tr("Localizable", "CloudBackup.recoverHeader")
    /// A previously backed up wallet has been detected. Using this backup is recommended. Are you sure you want to proceeed with restoring from a recovery phrase?
    internal static let recoverWarning = L10n.tr("Localizable", "CloudBackup.recoverWarning")
    /// Restore from iCloud Backup
    internal static let restoreButton = L10n.tr("Localizable", "CloudBackup.restoreButton")
    /// Choose Backup
    internal static let selectTitle = L10n.tr("Localizable", "CloudBackup.selectTitle")
    /// Launch the Settings app.
    internal static let step1 = L10n.tr("Localizable", "CloudBackup.step1")
    /// Tap your Apple ID name.
    internal static let step2 = L10n.tr("Localizable", "CloudBackup.step2")
    /// Tap iCloud.
    internal static let step3 = L10n.tr("Localizable", "CloudBackup.step3")
    /// Verify that iCloud Keychain is ON
    internal static let step4 = L10n.tr("Localizable", "CloudBackup.step4")
    /// I understand that this feature will not work unless iCloud Keychain is enabled.
    internal static let understandText = L10n.tr("Localizable", "CloudBackup.understandText")
    /// Your iCloud backup will be erased after %1$@ more incorrect PIN attempts.
    internal static func warningBody(_ p1: Any) -> String {
      return L10n.tr("Localizable", "CloudBackup.warningBody", String(describing: p1))
    }
  }

  internal enum ConfirmGift {
    /// Paper Wallet Amount
    internal static let paperWalletAmount = L10n.tr("Localizable", "ConfirmGift.paperWalletAmount")
    /// Validating this paper wallet on the network may take up to 60 minutes
    internal static let processingTime = L10n.tr("Localizable", "ConfirmGift.processingTime")
  }

  internal enum ConfirmPaperPhrase {
    /// The words entered do not match your recovery phrase. Please try again.
    internal static let error = L10n.tr("Localizable", "ConfirmPaperPhrase.error")
    /// To make sure everything was written down correctly, please enter the following words from your recovery phrase.
    internal static let label = L10n.tr("Localizable", "ConfirmPaperPhrase.label")
    /// Word #%1$@
    internal static func word(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ConfirmPaperPhrase.word", String(describing: p1))
    }
  }

  internal enum Confirmation {
    /// Amount to Send:
    internal static let amountLabel = L10n.tr("Localizable", "Confirmation.amountLabel")
    /// Destination Tag
    internal static let destinationTag = L10n.tr("Localizable", "Confirmation.destinationTag")
    /// (empty)
    internal static let destinationTagEmptyHint = L10n.tr("Localizable", "Confirmation.destinationTag_EmptyHint")
    /// Network Fee:
    internal static let feeLabel = L10n.tr("Localizable", "Confirmation.feeLabel")
    /// Network Fee (ETH):
    internal static let feeLabelETH = L10n.tr("Localizable", "Confirmation.feeLabelETH")
    /// Hedera Memo
    internal static let hederaMemo = L10n.tr("Localizable", "Confirmation.hederaMemo")
    /// Processing time: This transaction is predicted to complete in %1$@.
    internal static func processingTime(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Confirmation.processingTime", String(describing: p1))
    }
    /// Send
    internal static let send = L10n.tr("Localizable", "Confirmation.send")
    /// Confirmation
    internal static let title = L10n.tr("Localizable", "Confirmation.title")
    /// To
    internal static let to = L10n.tr("Localizable", "Confirmation.to")
    /// Total Cost:
    internal static let totalLabel = L10n.tr("Localizable", "Confirmation.totalLabel")
  }

  internal enum CreateGift {
    /// Choose amount ($USD)
    internal static let amountLabel = L10n.tr("Localizable", "CreateGift.amountLabel")
    /// Create
    internal static let create = L10n.tr("Localizable", "CreateGift.create")
    /// Custom amount ($500 max)
    internal static let customAmountHint = L10n.tr("Localizable", "CreateGift.customAmountHint")
    /// We'll create what's called a
    internal static let description = L10n.tr("Localizable", "CreateGift.description")
    /// You must select a gift amount.
    internal static let inputAmountError = L10n.tr("Localizable", "CreateGift.inputAmountError")
    /// You must enter the name of the recipient.
    internal static let inputRecipientNameError = L10n.tr("Localizable", "CreateGift.inputRecipientNameError")
    /// You have insufficient funds to send a gift.
    internal static let insufficientBalanceError = L10n.tr("Localizable", "CreateGift.insufficientBalanceError")
    /// You have insufficient funds to send a gift of this amount.
    internal static let insufficientBalanceForAmountError = L10n.tr("Localizable", "CreateGift.insufficientBalanceForAmountError")
    /// Recipient's name
    internal static let recipientName = L10n.tr("Localizable", "CreateGift.recipientName")
    /// A server error occurred. Please try again later.
    internal static let serverError = L10n.tr("Localizable", "CreateGift.serverError")
    /// Send bitcoin to someone even if they don't have a wallet.
    internal static let subtitle = L10n.tr("Localizable", "CreateGift.subtitle")
    /// Give the Gift of Bitcoin
    internal static let title = L10n.tr("Localizable", "CreateGift.title")
    /// An unexpected error occurred. Please contact support.
    internal static let unexpectedError = L10n.tr("Localizable", "CreateGift.unexpectedError")
  }

  internal enum Crowdsale {
    /// Agree
    internal static let agree = L10n.tr("Localizable", "Crowdsale.agree")
    /// Buy Tokens
    internal static let buyButton = L10n.tr("Localizable", "Crowdsale.buyButton")
    /// Decline
    internal static let decline = L10n.tr("Localizable", "Crowdsale.decline")
    /// Resume Verification
    internal static let resume = L10n.tr("Localizable", "Crowdsale.resume")
    /// Retry
    internal static let retry = L10n.tr("Localizable", "Crowdsale.retry")
  }

  internal enum DefaultCurrency {
    /// Bitcoin Display Unit
    internal static let bitcoinLabel = L10n.tr("Localizable", "DefaultCurrency.bitcoinLabel")
    /// Exchange Rate
    internal static let rateLabel = L10n.tr("Localizable", "DefaultCurrency.rateLabel")
  }

  internal enum Disabled {
    /// Wallet disabled
    internal static let title = L10n.tr("Localizable", "Disabled.title")
  }

  internal enum Eme {
    internal enum Permissions {
      /// Request %1$@ account information
      internal static func accountRequest(_ p1: Any) -> String {
        return L10n.tr("Localizable", "EME.permissions.accountRequest", String(describing: p1))
      }
      /// Request %1$@ smart contract call
      internal static func callRequest(_ p1: Any) -> String {
        return L10n.tr("Localizable", "EME.permissions.callRequest", String(describing: p1))
      }
      /// Request %1$@ payment
      internal static func paymentRequest(_ p1: Any) -> String {
        return L10n.tr("Localizable", "EME.permissions.paymentRequest", String(describing: p1))
      }
    }
  }

  internal enum Email {
    /// %1$s Address
    internal static func addressSubject(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Email.address_subject", p1)
    }
  }

  internal enum ErrorMessages {
    /// This device isn't configured to send email with the iOS mail app.
    internal static let emailUnavailableMessage = L10n.tr("Localizable", "ErrorMessages.emailUnavailableMessage")
    /// Email Unavailable
    internal static let emailUnavailableTitle = L10n.tr("Localizable", "ErrorMessages.emailUnavailableTitle")
    /// Insufficient Ethereum balance in your wallet to transfer this type of token.
    internal static let ethBalanceLow = L10n.tr("Localizable", "ErrorMessages.ethBalanceLow")
    /// This device isn't configured to send messages.
    internal static let messagingUnavailableMessage = L10n.tr("Localizable", "ErrorMessages.messagingUnavailableMessage")
    /// Messaging Unavailable
    internal static let messagingUnavailableTitle = L10n.tr("Localizable", "ErrorMessages.messagingUnavailableTitle")
    internal enum LoopingLockScreen {
      /// Fabriik can not be authenticated due to a bug in your version of Android. [Please tap here for more information.]
      internal static let android = L10n.tr("Localizable", "ErrorMessages.loopingLockScreen.android")
    }
    internal enum TouchIdFailed {
      /// Fingerprint not recognized. Please try again.
      internal static let android = L10n.tr("Localizable", "ErrorMessages.touchIdFailed.android")
    }
  }

  internal enum ExportConfirmation {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "ExportConfirmation.cancel")
    /// Continue
    internal static let `continue` = L10n.tr("Localizable", "ExportConfirmation.continue")
    /// This will generate a CSV file including all completed transactions from all enabled wallets.
    internal static let message = L10n.tr("Localizable", "ExportConfirmation.message")
    /// Export transactions?
    internal static let title = L10n.tr("Localizable", "ExportConfirmation.title")
  }

  internal enum ExportTransfers {
    /// This will generate a CSV file including all completed transactions from all enabled wallets.
    internal static let body = L10n.tr("Localizable", "ExportTransfers.body")
    /// Export Transfers
    internal static let confirmExport = L10n.tr("Localizable", "ExportTransfers.confirmExport")
    /// Failed to export CSV file, please try again.
    internal static let exportFailedBody = L10n.tr("Localizable", "ExportTransfers.exportFailedBody")
    /// Export Failed
    internal static let exportFailedTitle = L10n.tr("Localizable", "ExportTransfers.exportFailedTitle")
    /// Export transactions?
    internal static let header = L10n.tr("Localizable", "ExportTransfers.header")
  }

  internal enum FaceIDSettings {
    /// You can customize your Face ID spending limit from the %1$@.
    internal static func customizeText(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FaceIDSettings.customizeText", String(describing: p1))
    }
    /// Use Face ID to unlock your Fabriik app and send money.
    internal static let explanatoryText = L10n.tr("Localizable", "FaceIDSettings.explanatoryText")
    /// Use your face to unlock your Fabriik and send money up to a set limit.
    internal static let label = L10n.tr("Localizable", "FaceIDSettings.label")
    /// Face ID Spending Limit Screen
    internal static let linkText = L10n.tr("Localizable", "FaceIDSettings.linkText")
    /// Enable Face ID for Fabriik
    internal static let switchLabel = L10n.tr("Localizable", "FaceIDSettings.switchLabel")
    /// Face ID
    internal static let title = L10n.tr("Localizable", "FaceIDSettings.title")
    /// Enable Face ID to send money
    internal static let transactionsTitleText = L10n.tr("Localizable", "FaceIDSettings.transactionsTitleText")
    /// You have not set up Face ID on this device. Go to Settings->Face ID & Passcode to set it up now.
    internal static let unavailableAlertMessage = L10n.tr("Localizable", "FaceIDSettings.unavailableAlertMessage")
    /// Face ID Not Set Up
    internal static let unavailableAlertTitle = L10n.tr("Localizable", "FaceIDSettings.unavailableAlertTitle")
    /// Enable Face ID to unlock Fabriik
    internal static let unlockTitleText = L10n.tr("Localizable", "FaceIDSettings.unlockTitleText")
  }

  internal enum FaceIDSpendingLimit {
    /// Face ID Spending Limit
    internal static let title = L10n.tr("Localizable", "FaceIDSpendingLimit.title")
  }

  internal enum FeeSelector {
    /// Economy
    internal static let economy = L10n.tr("Localizable", "FeeSelector.economy")
    /// 1-24 hours
    internal static let economyTime = L10n.tr("Localizable", "FeeSelector.economyTime")
    /// This option is not recommended for time-sensitive transactions.
    internal static let economyWarning = L10n.tr("Localizable", "FeeSelector.economyWarning")
    /// Estimated Delivery: %1$@
    internal static func estimatedDeliver(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FeeSelector.estimatedDeliver", String(describing: p1))
    }
    /// 2-5 minutes
    internal static let ethTime = L10n.tr("Localizable", "FeeSelector.ethTime")
    /// <%1$d minutes
    internal static func lessThanMinutes(_ p1: Int) -> String {
      return L10n.tr("Localizable", "FeeSelector.lessThanMinutes", p1)
    }
    /// Priority
    internal static let priority = L10n.tr("Localizable", "FeeSelector.priority")
    /// 10-30 minutes
    internal static let priorityTime = L10n.tr("Localizable", "FeeSelector.priorityTime")
    /// Regular
    internal static let regular = L10n.tr("Localizable", "FeeSelector.regular")
    /// 10-60 minutes
    internal static let regularTime = L10n.tr("Localizable", "FeeSelector.regularTime")
    /// Processing Speed
    internal static let title = L10n.tr("Localizable", "FeeSelector.title")
  }

  internal enum FileChooser {
    internal enum SelectImageSource {
      /// Select Image Source
      internal static let android = L10n.tr("Localizable", "FileChooser.selectImageSource.android")
    }
  }

  internal enum FingerprintSettings {
    /// Use your fingerprint to unlock your Fabriik app and send transactions.
    internal static let description = L10n.tr("Localizable", "FingerprintSettings.description")
    /// Use fingerprint to send money
    internal static let sendMoney = L10n.tr("Localizable", "FingerprintSettings.sendMoney")
    /// Fingerprint
    internal static let title = L10n.tr("Localizable", "FingerprintSettings.title")
    /// Use fingerprint to unlock Fabriik
    internal static let unlockApp = L10n.tr("Localizable", "FingerprintSettings.unlockApp")
  }

  internal enum HomeScreen {
    /// Activity
    internal static let activity = L10n.tr("Localizable", "HomeScreen.activity")
    /// Admin
    internal static let admin = L10n.tr("Localizable", "HomeScreen.admin")
    /// Buy
    internal static let buy = L10n.tr("Localizable", "HomeScreen.buy")
    /// Buy & Sell
    internal static let buyAndSell = L10n.tr("Localizable", "HomeScreen.buyAndSell")
    /// Menu
    internal static let menu = L10n.tr("Localizable", "HomeScreen.menu")
    /// Wallets
    internal static let portfolio = L10n.tr("Localizable", "HomeScreen.portfolio")
    /// Total Assets
    internal static let totalAssets = L10n.tr("Localizable", "HomeScreen.totalAssets")
    /// Swap
    internal static let trade = L10n.tr("Localizable", "HomeScreen.trade")
  }

  internal enum Import {
    /// Checking private key balance...
    internal static let checking = L10n.tr("Localizable", "Import.checking")
    /// Send %1$@ from this private key into your wallet? The bitcoin network will receive a fee of %2$@.
    internal static func confirm(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "Import.confirm", String(describing: p1), String(describing: p2))
    }
    /// Import
    internal static let importButton = L10n.tr("Localizable", "Import.importButton")
    /// Importing Wallet
    internal static let importing = L10n.tr("Localizable", "Import.importing")
    /// Wallet to be imported
    internal static let leftCaption = L10n.tr("Localizable", "Import.leftCaption")
    /// Importing a wallet transfers all the money from your other wallet into your Fabriik wallet using a single transaction.
    internal static let message = L10n.tr("Localizable", "Import.message")
    /// This private key is password protected.
    internal static let password = L10n.tr("Localizable", "Import.password")
    /// password
    internal static let passwordPlaceholder = L10n.tr("Localizable", "Import.passwordPlaceholder")
    /// Your Fabriik Wallet
    internal static let rightCaption = L10n.tr("Localizable", "Import.rightCaption")
    /// Scan Private Key
    internal static let scan = L10n.tr("Localizable", "Import.scan")
    /// Success
    internal static let success = L10n.tr("Localizable", "Import.success")
    /// Successfully imported wallet.
    internal static let successBody = L10n.tr("Localizable", "Import.SuccessBody")
    /// Import Wallet
    internal static let title = L10n.tr("Localizable", "Import.title")
    /// Unlocking Key
    internal static let unlockingActivity = L10n.tr("Localizable", "Import.unlockingActivity")
    /// Importing a wallet does not include transaction history or other details.
    internal static let warning = L10n.tr("Localizable", "Import.warning")
    /// Wrong password, please try again.
    internal static let wrongPassword = L10n.tr("Localizable", "Import.wrongPassword")
    internal enum Error {
      /// This private key is already in your wallet.
      internal static let duplicate = L10n.tr("Localizable", "Import.Error.duplicate")
      /// This private key is empty.
      internal static let empty = L10n.tr("Localizable", "Import.Error.empty")
      /// Failed to submit transaction.
      internal static let failedSubmit = L10n.tr("Localizable", "Import.Error.failedSubmit")
      /// Transaction fees would cost more than the funds available on this private key.
      internal static let highFees = L10n.tr("Localizable", "Import.Error.highFees")
      /// Not a valid private key
      internal static let notValid = L10n.tr("Localizable", "Import.Error.notValid")
      /// Service Error
      internal static let serviceError = L10n.tr("Localizable", "Import.Error.serviceError")
      /// Service Unavailable
      internal static let serviceUnavailable = L10n.tr("Localizable", "Import.Error.serviceUnavailable")
      /// Error signing transaction
      internal static let signing = L10n.tr("Localizable", "Import.Error.signing")
      /// Unable to sweep wallet
      internal static let sweepError = L10n.tr("Localizable", "Import.Error.sweepError")
      /// Unsupported Currency
      internal static let unsupportedCurrency = L10n.tr("Localizable", "Import.Error.unsupportedCurrency")
    }
  }

  internal enum JailbreakWarnings {
    /// Close
    internal static let close = L10n.tr("Localizable", "JailbreakWarnings.close")
    /// Ignore
    internal static let ignore = L10n.tr("Localizable", "JailbreakWarnings.ignore")
    /// DEVICE SECURITY COMPROMISED
    ///  Any 'jailbreak' app can access Fabriik's keychain data and steal your bitcoin! Wipe this wallet immediately and restore on a secure device.
    internal static let messageWithBalance = L10n.tr("Localizable", "JailbreakWarnings.messageWithBalance")
    /// DEVICE SECURITY COMPROMISED
    ///  Any 'jailbreak' app can access Fabriik's keychain data and steal your bitcoin. Please only use Fabriik on a non-jailbroken device.
    internal static let messageWithoutBalance = L10n.tr("Localizable", "JailbreakWarnings.messageWithoutBalance")
    /// WARNING
    internal static let title = L10n.tr("Localizable", "JailbreakWarnings.title")
    /// Wipe
    internal static let wipe = L10n.tr("Localizable", "JailbreakWarnings.wipe")
  }

  internal enum LinkWallet {
    /// Approve
    internal static let approve = L10n.tr("Localizable", "LinkWallet.approve")
    /// Decline
    internal static let decline = L10n.tr("Localizable", "LinkWallet.decline")
    /// External apps cannot send money without approval from this device
    internal static let disclaimer = L10n.tr("Localizable", "LinkWallet.disclaimer")
    /// Note: ONLY interact with this app when on one of the following domains
    internal static let domainTitle = L10n.tr("Localizable", "LinkWallet.domainTitle")
    /// Secure Checkout
    internal static let logoFooter = L10n.tr("Localizable", "LinkWallet.logoFooter")
    /// This app will be able to:
    internal static let permissionsTitle = L10n.tr("Localizable", "LinkWallet.permissionsTitle")
    /// Link Wallet
    internal static let title = L10n.tr("Localizable", "LinkWallet.title")
  }

  internal enum LocationPlugin {
    /// Location services are disabled.
    internal static let disabled = L10n.tr("Localizable", "LocationPlugin.disabled")
    /// Fabriik does not have permission to access location services.
    internal static let notAuthorized = L10n.tr("Localizable", "LocationPlugin.notAuthorized")
  }

  internal enum ManageWallet {
    /// You created your wallet on %1$@
    internal static func creationDatePrefix(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ManageWallet.creationDatePrefix", String(describing: p1))
    }
    /// Your wallet name only appears in your account transaction history and cannot be seen by anyone else.
    internal static let description = L10n.tr("Localizable", "ManageWallet.description")
    /// Wallet Name
    internal static let textFeildLabel = L10n.tr("Localizable", "ManageWallet.textFeildLabel")
    /// Manage Wallet
    internal static let title = L10n.tr("Localizable", "ManageWallet.title")
  }

  internal enum MarketData {
    /// 24h high
    internal static let high24h = L10n.tr("Localizable", "MarketData.high24h")
    /// 24h low
    internal static let low24h = L10n.tr("Localizable", "MarketData.low24h")
    /// Market Cap
    internal static let marketCap = L10n.tr("Localizable", "MarketData.marketCap")
    /// Trading Volume
    internal static let volume = L10n.tr("Localizable", "MarketData.volume")
  }

  internal enum MenuButton {
    /// Add Wallet
    internal static let addWallet = L10n.tr("Localizable", "MenuButton.addWallet")
    /// ATM Cash Redemption
    internal static let atmCashRedemption = L10n.tr("Localizable", "MenuButton.atmCashRedemption")
    /// Support
    internal static let feedback = L10n.tr("Localizable", "MenuButton.feedback")
    /// Lock Wallet
    internal static let lock = L10n.tr("Localizable", "MenuButton.lock")
    /// Manage Assets
    internal static let manageAssets = L10n.tr("Localizable", "MenuButton.manageAssets")
    /// Manage Wallets
    internal static let manageWallets = L10n.tr("Localizable", "MenuButton.manageWallets")
    /// Scan QR Code
    internal static let scan = L10n.tr("Localizable", "MenuButton.scan")
    /// Security Settings
    internal static let security = L10n.tr("Localizable", "MenuButton.security")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "MenuButton.settings")
    /// Support
    internal static let support = L10n.tr("Localizable", "MenuButton.support")
  }

  internal enum MenuViewController {
    /// Create New Wallet
    internal static let createButton = L10n.tr("Localizable", "MenuViewController.createButton")
    /// Menu
    internal static let modalTitle = L10n.tr("Localizable", "MenuViewController.modalTitle")
    /// Recover Wallet
    internal static let recoverButton = L10n.tr("Localizable", "MenuViewController.recoverButton")
  }

  internal enum Modal {
    internal enum PaperKeySkip {
      /// Attention
      internal static let title = L10n.tr("Localizable", "Modal.PaperKeySkip.Title")
      internal enum Body {
        /// Your recovery phrase is required to open your wallet if you change the security settings on your phone.
        /// 
        /// Are you sure you want to set up your recovery phrase later?
        internal static let android = L10n.tr("Localizable", "Modal.PaperKeySkip.Body.Android")
      }
      internal enum Button {
        /// Continue Set Up
        internal static let continueSetUp = L10n.tr("Localizable", "Modal.PaperKeySkip.Button.ContinueSetUp")
        /// I'll do it later
        internal static let illDoItLater = L10n.tr("Localizable", "Modal.PaperKeySkip.Button.IllDoItLater")
      }
    }
  }

  internal enum NodeSelector {
    /// Automatic
    internal static let automatic = L10n.tr("Localizable", "NodeSelector.automatic")
    /// Switch to Automatic Mode
    internal static let automaticButton = L10n.tr("Localizable", "NodeSelector.automaticButton")
    /// Connected
    internal static let connected = L10n.tr("Localizable", "NodeSelector.connected")
    /// Connecting
    internal static let connecting = L10n.tr("Localizable", "NodeSelector.connecting")
    /// Enter Node IP address and port (optional)
    internal static let enterBody = L10n.tr("Localizable", "NodeSelector.enterBody")
    /// Enter Node
    internal static let enterTitle = L10n.tr("Localizable", "NodeSelector.enterTitle")
    /// Invalid Node
    internal static let invalid = L10n.tr("Localizable", "NodeSelector.invalid")
    /// Switch to Manual Mode
    internal static let manualButton = L10n.tr("Localizable", "NodeSelector.manualButton")
    /// Current Primary Node
    internal static let nodeLabel = L10n.tr("Localizable", "NodeSelector.nodeLabel")
    /// Not Connected
    internal static let notConnected = L10n.tr("Localizable", "NodeSelector.notConnected")
    /// Node Connection Status
    internal static let statusLabel = L10n.tr("Localizable", "NodeSelector.statusLabel")
    /// Bitcoin Nodes
    internal static let title = L10n.tr("Localizable", "NodeSelector.title")
  }

  internal enum Onboarding {
    /// I'll browse first
    internal static let browseFirst = L10n.tr("Localizable", "Onboarding.browseFirst")
    /// Buy some coin
    internal static let buyCoin = L10n.tr("Localizable", "Onboarding.buyCoin")
    /// Get started
    internal static let getStarted = L10n.tr("Localizable", "Onboarding.getStarted")
    /// Next
    internal static let next = L10n.tr("Localizable", "Onboarding.next")
    /// Restore wallet
    internal static let restoreWallet = L10n.tr("Localizable", "Onboarding.restoreWallet")
    /// Skip
    internal static let skip = L10n.tr("Localizable", "Onboarding.skip")
  }

  internal enum OnboardingPageFour {
    /// Start investing today with as little as $50!
    internal static let title = L10n.tr("Localizable", "OnboardingPageFour.title")
  }

  internal enum OnboardingPageOne {
    /// Welcome to your new digital asset wallet!
    internal static let title = L10n.tr("Localizable", "OnboardingPageOne.title")
  }

  internal enum OnboardingPageThree {
    /// Invest and diversify with Fabriik, easily and securely.
    internal static let subtitle = L10n.tr("Localizable", "OnboardingPageThree.subtitle")
    /// Buy and swap bitcoin, tokens, and other digital currencies.
    internal static let title = L10n.tr("Localizable", "OnboardingPageThree.title")
  }

  internal enum OnboardingPageTwo {
    /// We have over $6 billion USD worth of assets under protection.
    internal static let subtitle = L10n.tr("Localizable", "OnboardingPageTwo.subtitle")
    /// Join people around the world who trust Fabriik.
    internal static let title = L10n.tr("Localizable", "OnboardingPageTwo.title")
  }

  internal enum PaymentConfirmation {
    /// Send %1$@ to purchase %2$@
    internal static func amountText(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "PaymentConfirmation.amountText", String(describing: p1), String(describing: p2))
    }
    /// Confirmation
    internal static let title = L10n.tr("Localizable", "PaymentConfirmation.title")
  }

  internal enum PaymentProtocol {
    internal enum Errors {
      /// Bad Payment Request
      internal static let badPaymentRequest = L10n.tr("Localizable", "PaymentProtocol.Errors.badPaymentRequest")
      /// Unsupported or corrupted document
      internal static let corruptedDocument = L10n.tr("Localizable", "PaymentProtocol.Errors.corruptedDocument")
      /// missing certificate
      internal static let missingCertificate = L10n.tr("Localizable", "PaymentProtocol.Errors.missingCertificate")
      /// request expired
      internal static let requestExpired = L10n.tr("Localizable", "PaymentProtocol.Errors.requestExpired")
      /// Couldn't make payment
      internal static let smallOutputError = L10n.tr("Localizable", "PaymentProtocol.Errors.smallOutputError")
      /// Payment can’t be less than %1$@. Bitcoin transaction fees are more than the amount of this transaction. Please increase the amount and try again.
      internal static func smallPayment(_ p1: Any) -> String {
        return L10n.tr("Localizable", "PaymentProtocol.Errors.smallPayment", String(describing: p1))
      }
      /// Bitcoin transaction outputs can't be less than %1$@.
      internal static func smallTransaction(_ p1: Any) -> String {
        return L10n.tr("Localizable", "PaymentProtocol.Errors.smallTransaction", String(describing: p1))
      }
      /// unsupported signature type
      internal static let unsupportedSignatureType = L10n.tr("Localizable", "PaymentProtocol.Errors.unsupportedSignatureType")
      /// untrusted certificate
      internal static let untrustedCertificate = L10n.tr("Localizable", "PaymentProtocol.Errors.untrustedCertificate")
    }
  }

  internal enum Platform {
    /// Transaction Cancelled
    internal static let transactionCancelled = L10n.tr("Localizable", "Platform.transaction_cancelled")
  }

  internal enum Prompts {
    internal enum Email {
      /// Be the first to receive important support and product updates
      internal static let body = L10n.tr("Localizable", "Prompts.Email.body")
      /// enter your email
      internal static let placeholder = L10n.tr("Localizable", "Prompts.Email.placeholder")
      /// You have successfully subscribed to receive updates
      internal static let successBody = L10n.tr("Localizable", "Prompts.Email.successBody")
      /// We appreciate your continued support
      internal static let successFootnote = L10n.tr("Localizable", "Prompts.Email.successFootnote")
      /// Thank you!
      internal static let successTitle = L10n.tr("Localizable", "Prompts.Email.successTitle")
      /// Get in the loop
      internal static let title = L10n.tr("Localizable", "Prompts.Email.title")
    }
    internal enum FaceId {
      /// Tap Continue to enable Face ID
      internal static let body = L10n.tr("Localizable", "Prompts.FaceId.body")
      /// Enable Face ID
      internal static let title = L10n.tr("Localizable", "Prompts.FaceId.title")
    }
    internal enum NoPasscode {
      /// A device passcode is needed to safeguard your wallet. Go to settings and turn passcode on.
      internal static let body = L10n.tr("Localizable", "Prompts.NoPasscode.body")
      /// Turn device passcode on
      internal static let title = L10n.tr("Localizable", "Prompts.NoPasscode.title")
    }
    internal enum NoScreenLock {
      internal enum Body {
        /// A device screen lock is needed to safeguard your wallet. Enable screen lock in your settings to continue.
        internal static let android = L10n.tr("Localizable", "Prompts.NoScreenLock.body.android")
      }
      internal enum Title {
        /// Screen lock disabled
        internal static let android = L10n.tr("Localizable", "Prompts.NoScreenLock.title.android")
      }
    }
    internal enum PaperKey {
      /// Please write down your recovery phrase and store it somewhere that is safe and secure.
      internal static let body = L10n.tr("Localizable", "Prompts.PaperKey.body")
      /// Action Required
      internal static let title = L10n.tr("Localizable", "Prompts.PaperKey.title")
      internal enum Body {
        /// Set up your recovery phrase in case you ever lose or replace your phone. Your key is also required if you change your phone's security settings.
        internal static let android = L10n.tr("Localizable", "Prompts.PaperKey.Body.Android")
      }
    }
    internal enum RateApp {
      /// Don't ask again
      internal static let dontShow = L10n.tr("Localizable", "Prompts.RateApp.dontShow")
      /// Enjoying Fabriik?
      internal static let enjoyingBrd = L10n.tr("Localizable", "Prompts.RateApp.enjoyingBrd")
      /// Enjoying Fabriik?
      internal static let enjoyingFabriik = L10n.tr("Localizable", "Prompts.RateApp.enjoyingFabriik")
      /// Your review helps grow the Fabriik community.
      internal static let googlePlayReview = L10n.tr("Localizable", "Prompts.RateApp.googlePlayReview")
      /// No thanks
      internal static let noThanks = L10n.tr("Localizable", "Prompts.RateApp.noThanks")
      /// Review us
      internal static let rateUs = L10n.tr("Localizable", "Prompts.RateApp.rateUs")
    }
    internal enum RecommendRescan {
      /// Your wallet may be out of sync. This can often be fixed by rescanning the blockchain.
      internal static let body = L10n.tr("Localizable", "Prompts.RecommendRescan.body")
      /// Transaction Rejected
      internal static let title = L10n.tr("Localizable", "Prompts.RecommendRescan.title")
    }
    internal enum ShareData {
      /// Help improve Fabriik by sharing your anonymous data with us
      internal static let body = L10n.tr("Localizable", "Prompts.ShareData.body")
      /// Share Anonymous Data
      internal static let title = L10n.tr("Localizable", "Prompts.ShareData.title")
    }
    internal enum TouchId {
      /// Tap Continue to enable Touch ID
      internal static let body = L10n.tr("Localizable", "Prompts.TouchId.body")
      /// Enable Touch ID
      internal static let title = L10n.tr("Localizable", "Prompts.TouchId.title")
      internal enum Body {
        /// Tap here to enable fingerprint authentication
        internal static let android = L10n.tr("Localizable", "Prompts.TouchId.body.android")
      }
      internal enum Title {
        /// Enable Fingerprint Authentication
        internal static let android = L10n.tr("Localizable", "Prompts.TouchId.title.android")
      }
      internal enum UsePin {
        /// PIN
        internal static let android = L10n.tr("Localizable", "Prompts.TouchId.usePin.android")
      }
    }
    internal enum UpgradePin {
      /// Fabriik has upgraded to using a 6-digit PIN. Tap Continue to upgrade.
      internal static let body = L10n.tr("Localizable", "Prompts.UpgradePin.body")
      /// Upgrade PIN
      internal static let title = L10n.tr("Localizable", "Prompts.UpgradePin.title")
    }
  }

  internal enum PushNotifications {
    /// Turn on push notifications and be the first to hear about new features and special offers.
    internal static let body = L10n.tr("Localizable", "PushNotifications.body")
    /// Notifications Disabled
    internal static let disabled = L10n.tr("Localizable", "PushNotifications.disabled")
    /// Turn on notifications to receive special offers and updates from Fabriik.
    internal static let disabledBody = L10n.tr("Localizable", "PushNotifications.disabledBody")
    /// You’re receiving special offers and updates from Fabriik.
    internal static let enabledBody = L10n.tr("Localizable", "PushNotifications.enabledBody")
    /// Looks like notifications are turned off. Please go to Settings to enable notifications from Fabriik.
    internal static let enableInstructions = L10n.tr("Localizable", "PushNotifications.enableInstructions")
    /// Receive Push Notifications
    internal static let label = L10n.tr("Localizable", "PushNotifications.label")
    /// Off
    internal static let off = L10n.tr("Localizable", "PushNotifications.off")
    /// On
    internal static let on = L10n.tr("Localizable", "PushNotifications.on")
    /// Stay in the Loop
    internal static let title = L10n.tr("Localizable", "PushNotifications.title")
    /// Failed to update push notifications settings
    internal static let updateFailed = L10n.tr("Localizable", "PushNotifications.updateFailed")
  }

  internal enum RateAppPrompt {
    internal enum Body {
      /// If you love our app, please take a moment to rate it and give us a review.
      internal static let android = L10n.tr("Localizable", "RateAppPrompt.Body.Android")
    }
    internal enum Button {
      internal enum Dismiss {
        /// No Thanks
        internal static let android = L10n.tr("Localizable", "RateAppPrompt.Button.Dismiss.Android")
      }
      internal enum RateApp {
        /// Rate Fabriik
        internal static let android = L10n.tr("Localizable", "RateAppPrompt.Button.RateApp.Android")
      }
    }
    internal enum Title {
      /// Rate Fabriik
      internal static let android = L10n.tr("Localizable", "RateAppPrompt.Title.Android")
    }
  }

  internal enum ReScan {
    /// Sync
    internal static let alertAction = L10n.tr("Localizable", "ReScan.alertAction")
    /// You will not be able to send money while syncing.
    internal static let alertMessage = L10n.tr("Localizable", "ReScan.alertMessage")
    /// Sync with Blockchain?
    internal static let alertTitle = L10n.tr("Localizable", "ReScan.alertTitle")
    /// 20-45 minutes
    internal static let body1 = L10n.tr("Localizable", "ReScan.body1")
    /// If a transaction shows as completed on the network but not in your Fabriik.
    internal static let body2 = L10n.tr("Localizable", "ReScan.body2")
    /// You repeatedly get an error saying your transaction was rejected.
    internal static let body3 = L10n.tr("Localizable", "ReScan.body3")
    /// Start Sync
    internal static let buttonTitle = L10n.tr("Localizable", "ReScan.buttonTitle")
    /// You will not be able to send money while syncing with the blockchain.
    internal static let footer = L10n.tr("Localizable", "ReScan.footer")
    /// Sync Blockchain
    internal static let header = L10n.tr("Localizable", "ReScan.header")
    /// Estimated time
    internal static let subheader1 = L10n.tr("Localizable", "ReScan.subheader1")
    /// When to Sync?
    internal static let subheader2 = L10n.tr("Localizable", "ReScan.subheader2")
  }

  internal enum Receive {
    /// Copied to clipboard.
    internal static let copied = L10n.tr("Localizable", "Receive.copied")
    /// Email
    internal static let emailButton = L10n.tr("Localizable", "Receive.emailButton")
    /// Request an Amount
    internal static let request = L10n.tr("Localizable", "Receive.request")
    /// Share
    internal static let share = L10n.tr("Localizable", "Receive.share")
    /// Text Message
    internal static let textButton = L10n.tr("Localizable", "Receive.textButton")
    /// Receive
    internal static let title = L10n.tr("Localizable", "Receive.title")
  }

  internal enum RecoverWallet {
    /// Done
    internal static let done = L10n.tr("Localizable", "RecoverWallet.done")
    /// Recover Wallet
    internal static let header = L10n.tr("Localizable", "RecoverWallet.header")
    /// Reset PIN
    internal static let headerResetPin = L10n.tr("Localizable", "RecoverWallet.header_reset_pin")
    /// Enter Recovery Phrase
    internal static let instruction = L10n.tr("Localizable", "RecoverWallet.instruction")
    /// Recover your Fabriik with your recovery phrase.
    internal static let intro = L10n.tr("Localizable", "RecoverWallet.intro")
    /// The recovery phrase you entered is invalid. Please double-check each word and try again.
    internal static let invalid = L10n.tr("Localizable", "RecoverWallet.invalid")
    /// Left Arrow
    internal static let leftArrow = L10n.tr("Localizable", "RecoverWallet.leftArrow")
    /// Next
    internal static let next = L10n.tr("Localizable", "RecoverWallet.next")
    /// Tap here for more information.
    internal static let resetPinMoreInfo = L10n.tr("Localizable", "RecoverWallet.reset_pin_more_info")
    /// Right Arrow
    internal static let rightArrow = L10n.tr("Localizable", "RecoverWallet.rightArrow")
    /// Enter the recovery phrase for the wallet you want to recover.
    internal static let subheader = L10n.tr("Localizable", "RecoverWallet.subheader")
    /// To reset your PIN, enter the words from your recovery phrase into the boxes below.
    internal static let subheaderResetPin = L10n.tr("Localizable", "RecoverWallet.subheader_reset_pin")
  }

  internal enum RecoveryKeyFlow {
    /// The word you entered is incorrect. Please try again.
    internal static let confirmRecoveryInputError = L10n.tr("Localizable", "RecoveryKeyFlow.confirmRecoveryInputError")
    /// Almost done! Enter the following words from your recovery phrase.
    internal static let confirmRecoveryKeySubtitle = L10n.tr("Localizable", "RecoveryKeyFlow.confirmRecoveryKeySubtitle")
    /// Confirm Recovery Phrase
    internal static let confirmRecoveryKeyTitle = L10n.tr("Localizable", "RecoveryKeyFlow.confirmRecoveryKeyTitle")
    /// Enter Recovery Phrase
    internal static let enterRecoveryKey = L10n.tr("Localizable", "RecoveryKeyFlow.enterRecoveryKey")
    /// Please enter your recovery phrase to unlink this wallet from your device.
    internal static let enterRecoveryKeySubtitle = L10n.tr("Localizable", "RecoveryKeyFlow.enterRecoveryKeySubtitle")
    /// Are you sure you want to set up your recovery phrase later?
    internal static let exitRecoveryKeyPromptBody = L10n.tr("Localizable", "RecoveryKeyFlow.exitRecoveryKeyPromptBody")
    /// Set Up Later
    internal static let exitRecoveryKeyPromptTitle = L10n.tr("Localizable", "RecoveryKeyFlow.exitRecoveryKeyPromptTitle")
    /// Generate Recovery Phrase
    internal static let generateKeyButton = L10n.tr("Localizable", "RecoveryKeyFlow.generateKeyButton")
    /// This key is required to recover your money if you upgrade or lose your phone.
    internal static let generateKeyExplanation = L10n.tr("Localizable", "RecoveryKeyFlow.generateKeyExplanation")
    /// Generate your private recovery phrase
    internal static let generateKeyTitle = L10n.tr("Localizable", "RecoveryKeyFlow.generateKeyTitle")
    /// Go to Wallet
    internal static let goToWalletButtonTitle = L10n.tr("Localizable", "RecoveryKeyFlow.goToWalletButtonTitle")
    /// How it works - Step %1$@
    internal static func howItWorksStep(_ p1: Any) -> String {
      return L10n.tr("Localizable", "RecoveryKeyFlow.howItWorksStep", String(describing: p1))
    }
    /// Some of the words you entered do not match your recovery phrase. Please try again.
    internal static let invalidPhrase = L10n.tr("Localizable", "RecoveryKeyFlow.invalidPhrase")
    /// Keep it secure
    internal static let keepSecure = L10n.tr("Localizable", "RecoveryKeyFlow.keepSecure")
    /// Your key is only needed for recovery, not for everyday wallet access.
    internal static let keyUseHint = L10n.tr("Localizable", "RecoveryKeyFlow.keyUseHint")
    /// For security purposes, do not screenshot or email these words
    internal static let noScreenshotsOrEmailWarning = L10n.tr("Localizable", "RecoveryKeyFlow.noScreenshotsOrEmailWarning")
    /// Write down your key on paper and confirm it. Screenshots are not recommended for security reasons.
    internal static let noScreenshotsRecommendation = L10n.tr("Localizable", "RecoveryKeyFlow.noScreenshotsRecommendation")
    /// Recover Your Wallet
    internal static let recoveryYourWallet = L10n.tr("Localizable", "RecoveryKeyFlow.recoveryYourWallet")
    /// Please enter the recovery phrase of the wallet you want to recover.
    internal static let recoveryYourWalletSubtitle = L10n.tr("Localizable", "RecoveryKeyFlow.recoveryYourWalletSubtitle")
    /// Relax, buy, and swap
    internal static let relaxBuyTrade = L10n.tr("Localizable", "RecoveryKeyFlow.relaxBuyTrade")
    /// Remember to write these words down. Swipe back if you forgot.
    internal static let rememberToWriteDownReminder = L10n.tr("Localizable", "RecoveryKeyFlow.rememberToWriteDownReminder")
    /// Please enter your recovery phrase to reset your PIN.
    internal static let resetPINInstruction = L10n.tr("Localizable", "RecoveryKeyFlow.resetPINInstruction")
    /// Buy and swap knowing that your funds are protected by the best security and privacy in the business.
    internal static let securityAssurance = L10n.tr("Localizable", "RecoveryKeyFlow.securityAssurance")
    /// Store your key in a secure location. This is the only way to recover your wallet. Fabriik does not keep a copy.
    internal static let storeSecurelyRecommendation = L10n.tr("Localizable", "RecoveryKeyFlow.storeSecurelyRecommendation")
    /// Congratulations! You completed your recovery phrase setup.
    internal static let successHeading = L10n.tr("Localizable", "RecoveryKeyFlow.successHeading")
    /// You're all set to deposit, swap, and buy crypto from your Fabriik wallet.
    internal static let successSubheading = L10n.tr("Localizable", "RecoveryKeyFlow.successSubheading")
    /// Unlink your wallet from this device.
    internal static let unlinkWallet = L10n.tr("Localizable", "RecoveryKeyFlow.unlinkWallet")
    /// Start a new wallet by unlinking your device from the currently installed wallet.
    internal static let unlinkWalletSubtext = L10n.tr("Localizable", "RecoveryKeyFlow.unlinkWalletSubtext")
    /// Wallet must be recovered to regain access.
    internal static let unlinkWalletWarning = L10n.tr("Localizable", "RecoveryKeyFlow.unlinkWalletWarning")
    /// Wipe your wallet from this device.
    internal static let wipeWallet = L10n.tr("Localizable", "RecoveryKeyFlow.wipeWallet")
    /// Start a new wallet by wiping the current wallet from your device.
    internal static let wipeWalletSubtext = L10n.tr("Localizable", "RecoveryKeyFlow.wipeWalletSubtext")
    /// Write down your key
    internal static let writeItDown = L10n.tr("Localizable", "RecoveryKeyFlow.writeItDown")
    /// Write down your recovery phrase again
    internal static let writeKeyAgain = L10n.tr("Localizable", "RecoveryKeyFlow.writeKeyAgain")
    /// Write down the following words in order.
    internal static let writeKeyScreenSubtitle = L10n.tr("Localizable", "RecoveryKeyFlow.writeKeyScreenSubtitle")
    /// Your Recovery Phrase
    internal static let writeKeyScreenTitle = L10n.tr("Localizable", "RecoveryKeyFlow.writeKeyScreenTitle")
    /// %1$@ of %2$@
    internal static func writeKeyStepTitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "RecoveryKeyFlow.writeKeyStepTitle", String(describing: p1), String(describing: p2))
    }
  }

  internal enum RequestAnAmount {
    /// Please enter an amount first.
    internal static let noAmount = L10n.tr("Localizable", "RequestAnAmount.noAmount")
    /// Request an Amount
    internal static let title = L10n.tr("Localizable", "RequestAnAmount.title")
  }

  internal enum RewardsView {
    /// Learn how you can save on trading fees and unlock future rewards
    internal static let expandedBody = L10n.tr("Localizable", "RewardsView.expandedBody")
    /// Introducing Fabriik Rewards.
    internal static let expandedTitle = L10n.tr("Localizable", "RewardsView.expandedTitle")
    /// Rewards
    internal static let normalTitle = L10n.tr("Localizable", "RewardsView.normalTitle")
  }

  internal enum Scanner {
    /// Camera Flash
    internal static let flashButtonLabel = L10n.tr("Localizable", "Scanner.flashButtonLabel")
    /// Would you like to send a %1$@ payment to this address?
    internal static func paymentPromptMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Scanner.paymentPromptMessage", String(describing: p1))
    }
    /// Send Payment
    internal static let paymentPromptTitle = L10n.tr("Localizable", "Scanner.paymentPromptTitle")
  }

  internal enum Search {
    /// complete
    internal static let complete = L10n.tr("Localizable", "Search.complete")
    /// pending
    internal static let pending = L10n.tr("Localizable", "Search.pending")
    /// received
    internal static let received = L10n.tr("Localizable", "Search.received")
    /// Search
    internal static let search = L10n.tr("Localizable", "Search.search")
    /// sent
    internal static let sent = L10n.tr("Localizable", "Search.sent")
  }

  internal enum SecurityCenter {
    /// Face ID
    internal static let faceIdTitle = L10n.tr("Localizable", "SecurityCenter.faceIdTitle")
    /// The only way to access your assets if you lose or upgrade your phone.
    internal static let paperKeyDescription = L10n.tr("Localizable", "SecurityCenter.paperKeyDescription")
    /// Recovery Phrase
    internal static let paperKeyTitle = L10n.tr("Localizable", "SecurityCenter.paperKeyTitle")
    /// Protects your Fabriik from unauthorized users.
    internal static let pinDescription = L10n.tr("Localizable", "SecurityCenter.pinDescription")
    /// 6-Digit PIN
    internal static let pinTitle = L10n.tr("Localizable", "SecurityCenter.pinTitle")
    /// Conveniently unlock your Fabriik and send money up to a set limit.
    internal static let touchIdDescription = L10n.tr("Localizable", "SecurityCenter.touchIdDescription")
    /// Touch ID
    internal static let touchIdTitle = L10n.tr("Localizable", "SecurityCenter.touchIdTitle")
    internal enum PaperKeyTitle {
      /// Recovery Phrase
      internal static let android = L10n.tr("Localizable", "SecurityCenter.paperKeyTitle.android")
    }
    internal enum TouchIdTitle {
      /// Fingerprint Authentication
      internal static let android = L10n.tr("Localizable", "SecurityCenter.touchIdTitle.android")
    }
  }

  internal enum Segwit {
    /// You have enabled SegWit!
    internal static let confirmationConfirmationTitle = L10n.tr("Localizable", "Segwit.ConfirmationConfirmationTitle")
    /// Thank you for helping move bitcoin forward.
    internal static let confirmationInstructionsDescription = L10n.tr("Localizable", "Segwit.ConfirmationInstructionsDescription")
    /// SegWit support is still a beta feature.
    /// 
    /// Once SegWit is enabled, it will not be possible
    /// to disable it. You will be able to find the legacy address under Settings. 
    /// 
    /// Some third-party services, including crypto trading, may be unavailable to users who have enabled SegWit. In case of emergency, you will be able to generate a legacy address from Preferences > Bitcoin Settings. 
    /// 
    /// SegWit will automatically be enabled for all
    /// users in a future update.
    internal static let confirmationInstructionsInstructions = L10n.tr("Localizable", "Segwit.ConfirmationInstructionsInstructions")
    /// Enabling SegWit is an irreversible feature. Are you sure you want to continue?
    internal static let confirmChoiceLayout = L10n.tr("Localizable", "Segwit.ConfirmChoiceLayout")
    /// Enable
    internal static let enable = L10n.tr("Localizable", "Segwit.Enable")
    /// To the Moon
    internal static let homeButton = L10n.tr("Localizable", "Segwit.HomeButton")
  }

  internal enum Send {
    /// Amount
    internal static let amountLabel = L10n.tr("Localizable", "Send.amountLabel")
    /// Balance: %1$@
    internal static func balance(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Send.balance", String(describing: p1))
    }
    /// Balance:
    internal static let balanceString = L10n.tr("Localizable", "Send.balanceString")
    /// Go to Settings to allow camera access.
    internal static let cameraunavailableMessage = L10n.tr("Localizable", "Send.cameraunavailableMessage")
    /// Fabriik is not allowed to access the camera
    internal static let cameraUnavailableTitle = L10n.tr("Localizable", "Send.cameraUnavailableTitle")
    /// The destination is your own address. You cannot send to yourself.
    internal static let containsAddress = L10n.tr("Localizable", "Send.containsAddress")
    /// Could not create transaction.
    internal static let creatTransactionError = L10n.tr("Localizable", "Send.creatTransactionError")
    /// Memo
    internal static let descriptionLabel = L10n.tr("Localizable", "Send.descriptionLabel")
    /// Destination Tag
    internal static let destinationTagOptional = L10n.tr("Localizable", "Send.destinationTag_optional")
    /// Destination Tag (Required)
    internal static let destinationTagRequired = L10n.tr("Localizable", "Send.destinationTag_required")
    /// A valid Destination Tag is required for the target address.
    internal static let destinationTagRequiredError = L10n.tr("Localizable", "Send.destinationTag_required_error")
    /// Pasteboard is empty
    internal static let emptyPasteboard = L10n.tr("Localizable", "Send.emptyPasteboard")
    /// Can't send to self.
    internal static let ethSendSelf = L10n.tr("Localizable", "Send.ethSendSelf")
    /// Network Fee: %1$@
    internal static func fee(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Send.fee", String(describing: p1))
    }
    /// Invalid FIO address.
    internal static let fioInvalid = L10n.tr("Localizable", "Send.fio_invalid")
    /// There is no %1$s address associated with this FIO address.
    internal static func fioNoAddress(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Send.fio_noAddress", p1)
    }
    /// There was an error retrieving the address for this FIO address. Please try again later.
    internal static let fioRetrievalError = L10n.tr("Localizable", "Send.fio_retrievalError")
    /// Payee identity isn't certified.
    internal static let identityNotCertified = L10n.tr("Localizable", "Send.identityNotCertified")
    /// Insufficient Funds
    internal static let insufficientFunds = L10n.tr("Localizable", "Send.insufficientFunds")
    /// You must have at least %1$@ in your wallet in order to transfer this type of token. Would you like to go to your Ethereum wallet now?
    internal static func insufficientGasMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Send.insufficientGasMessage", String(describing: p1))
    }
    /// Insufficient Ethereum Balance
    internal static let insufficientGasTitle = L10n.tr("Localizable", "Send.insufficientGasTitle")
    /// The destination address is not a valid %1$@ address.
    internal static func invalidAddressMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Send.invalidAddressMessage", String(describing: p1))
    }
    /// Pasteboard does not contain a valid %1$@ address.
    internal static func invalidAddressOnPasteboard(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Send.invalidAddressOnPasteboard", String(describing: p1))
    }
    /// Invalid Address
    internal static let invalidAddressTitle = L10n.tr("Localizable", "Send.invalidAddressTitle")
    /// Sending is disabled during a full rescan.
    internal static let isRescanning = L10n.tr("Localizable", "Send.isRescanning")
    /// Warning: this is a legacy bitcoin address. Are you sure you want to send Bitcoin Cash to it?
    internal static let legacyAddressWarning = L10n.tr("Localizable", "Send.legacyAddressWarning")
    /// Loading Request
    internal static let loadingRequest = L10n.tr("Localizable", "Send.loadingRequest")
    /// Hedera Memo (Optional)
    internal static let memoTagOptional = L10n.tr("Localizable", "Send.memoTag_optional")
    /// Insufficient funds to cover the transaction fee.
    internal static let nilFeeError = L10n.tr("Localizable", "Send.nilFeeError")
    /// Please enter the recipient's address.
    internal static let noAddress = L10n.tr("Localizable", "Send.noAddress")
    /// Please enter an amount to send.
    internal static let noAmount = L10n.tr("Localizable", "Send.noAmount")
    /// Network Fee conditions are being downloaded. Please try again.
    internal static let noFeesError = L10n.tr("Localizable", "Send.noFeesError")
    /// Paste
    internal static let pasteLabel = L10n.tr("Localizable", "Send.pasteLabel")
    /// Invalid PayString.
    internal static let payIdInvalid = L10n.tr("Localizable", "Send.payId_invalid")
    /// There is no %1$s address associated with this PayString.
    internal static func payIdNoAddress(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Send.payId_noAddress", p1)
    }
    /// There was an error retrieving the address for this PayString. Please try again later.
    internal static let payIdRetrievalError = L10n.tr("Localizable", "Send.payId_retrievalError")
    /// PayString
    internal static let payIdToLabel = L10n.tr("Localizable", "Send.payId_toLabel")
    /// Could not publish transaction.
    internal static let publishTransactionError = L10n.tr("Localizable", "Send.publishTransactionError")
    /// Could not load payment request
    internal static let remoteRequestError = L10n.tr("Localizable", "Send.remoteRequestError")
    /// Scan
    internal static let scanLabel = L10n.tr("Localizable", "Send.scanLabel")
    /// Send Error
    internal static let sendError = L10n.tr("Localizable", "Send.sendError")
    /// Sending Max:
    internal static let sendingMax = L10n.tr("Localizable", "Send.sendingMax")
    /// Send
    internal static let sendLabel = L10n.tr("Localizable", "Send.sendLabel")
    /// Send maximum amount?
    internal static let sendMaximum = L10n.tr("Localizable", "Send.sendMaximum")
    /// Timed out waiting for network response. Please wait 30 minutes for confirmation before retrying.
    internal static let timeOutBody = L10n.tr("Localizable", "Send.timeOutBody")
    /// Send
    internal static let title = L10n.tr("Localizable", "Send.title")
    /// To
    internal static let toLabel = L10n.tr("Localizable", "Send.toLabel")
    internal enum Error {
      /// Authentication Error
      internal static let authenticationError = L10n.tr("Localizable", "Send.Error.authenticationError")
      /// Could not calculate maximum
      internal static let maxError = L10n.tr("Localizable", "Send.Error.maxError")
    }
    internal enum UsedAddress {
      /// Bitcoin addresses are intended for single use only.
      internal static let firstLine = L10n.tr("Localizable", "Send.UsedAddress.firstLine")
      /// Re-use reduces privacy for both you and the recipient and can result in loss if the recipient doesn't directly control the address.
      internal static let secondLIne = L10n.tr("Localizable", "Send.UsedAddress.secondLIne")
      /// Address Already Used
      internal static let title = L10n.tr("Localizable", "Send.UsedAddress.title")
    }
    internal enum CameraUnavailabeMessage {
      /// Allow camera access in "Settings" > "Apps" > "Fabriik" > "Permissions"
      internal static let android = L10n.tr("Localizable", "Send.cameraUnavailabeMessage.android")
    }
    internal enum CameraUnavailabeTitle {
      /// Fabriik is not allowed to access the camera
      internal static let android = L10n.tr("Localizable", "Send.cameraUnavailabeTitle.android")
    }
  }

  internal enum Settings {
    /// About
    internal static let about = L10n.tr("Localizable", "Settings.about")
    /// Advanced
    internal static let advanced = L10n.tr("Localizable", "Settings.advanced")
    /// Advanced Settings
    internal static let advancedTitle = L10n.tr("Localizable", "Settings.advancedTitle")
    /// Available in the USA only
    internal static let atmMapMenuItemSubtitle = L10n.tr("Localizable", "Settings.atmMapMenuItemSubtitle")
    /// Crypto ATM Map
    internal static let atmMapMenuItemTitle = L10n.tr("Localizable", "Settings.atmMapMenuItemTitle")
    /// Display Currency
    internal static let currency = L10n.tr("Localizable", "Settings.currency")
    /// %1$@ Settings
    internal static func currencyPageTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Settings.currencyPageTitle", String(describing: p1))
    }
    /// Currency Settings
    internal static let currencySettings = L10n.tr("Localizable", "Settings.currencySettings")
    /// Join Early Access
    internal static let earlyAccess = L10n.tr("Localizable", "Settings.earlyAccess")
    /// Enable Segwit
    internal static let enableSegwit = L10n.tr("Localizable", "Settings.EnableSegwit")
    /// Are you enjoying Fabriik?
    internal static let enjoying = L10n.tr("Localizable", "Settings.enjoying")
    /// Export transaction history to CSV
    internal static let exportTransfers = L10n.tr("Localizable", "Settings.exportTransfers")
    /// Face ID Spending Limit
    internal static let faceIdLimit = L10n.tr("Localizable", "Settings.faceIdLimit")
    /// Redeem Private Key
    internal static let importTitle = L10n.tr("Localizable", "Settings.importTitle")
    /// Manage
    internal static let manage = L10n.tr("Localizable", "Settings.manage")
    /// No Log files found. Please try again later.
    internal static let noLogsFound = L10n.tr("Localizable", "Settings.noLogsFound")
    /// Notifications
    internal static let notifications = L10n.tr("Localizable", "Settings.notifications")
    /// Other
    internal static let other = L10n.tr("Localizable", "Settings.other")
    /// Preferences
    internal static let preferences = L10n.tr("Localizable", "Settings.preferences")
    /// Reset to Default Currencies
    internal static let resetCurrencies = L10n.tr("Localizable", "Settings.resetCurrencies")
    /// Leave us a Review
    internal static let review = L10n.tr("Localizable", "Settings.review")
    /// Rewards
    internal static let rewards = L10n.tr("Localizable", "Settings.rewards")
    /// Share Anonymous Data
    internal static let shareData = L10n.tr("Localizable", "Settings.shareData")
    /// Share portfolio data with widgets
    internal static let shareWithWidget = L10n.tr("Localizable", "Settings.shareWithWidget")
    /// Sync Blockchain
    internal static let sync = L10n.tr("Localizable", "Settings.sync")
    /// Menu
    internal static let title = L10n.tr("Localizable", "Settings.title")
    /// Touch ID Spending Limit
    internal static let touchIdLimit = L10n.tr("Localizable", "Settings.touchIdLimit")
    /// View Legacy Receive Address
    internal static let viewLegacyAddress = L10n.tr("Localizable", "Settings.ViewLegacyAddress")
    /// Only send Bitcoin (BTC) to this address. Any other asset sent to this address will be lost permanently.
    internal static let viewLegacyAddressReceiveDescription = L10n.tr("Localizable", "Settings.ViewLegacyAddressReceiveDescription")
    /// Receive Bitcoin
    internal static let viewLegacyAddressReceiveTitle = L10n.tr("Localizable", "Settings.ViewLegacyAddressReceiveTitle")
    /// Wallets
    internal static let wallet = L10n.tr("Localizable", "Settings.wallet")
    /// Unlink from this device
    internal static let wipe = L10n.tr("Localizable", "Settings.wipe")
    internal enum TouchIdLimit {
      /// Fingerprint Authentication Spending Limit
      internal static let android = L10n.tr("Localizable", "Settings.touchIdLimit.android")
    }
    internal enum Wipe {
      /// Wipe wallet from this device
      internal static let android = L10n.tr("Localizable", "Settings.wipe.android")
    }
  }

  internal enum ShareData {
    /// Help improve Fabriik by sharing your anonymous data with us. This does not include any financial information. We respect your financial privacy.
    internal static let body = L10n.tr("Localizable", "ShareData.body")
    /// Share Data?
    internal static let header = L10n.tr("Localizable", "ShareData.header")
    /// Share Anonymous Data?
    internal static let toggleLabel = L10n.tr("Localizable", "ShareData.toggleLabel")
  }

  internal enum ShareGift {
    /// Approximate Total
    internal static let approximateTotal = L10n.tr("Localizable", "ShareGift.approximateTotal")
    /// A network fee will be deducted from the total when claimed.
    /// Actual value depends on current price of bitcoin.
    internal static let footerMessage1 = L10n.tr("Localizable", "ShareGift.footerMessage1")
    /// Download the Fabriik app for iPhone or Android.
    /// For more information visit Fabriik.com/gift
    internal static let footerMessage2 = L10n.tr("Localizable", "ShareGift.footerMessage2")
    /// Someone gifted you bitcoin!
    internal static let tagLine = L10n.tr("Localizable", "ShareGift.tagLine")
    /// Bitcoin
    internal static let walletName = L10n.tr("Localizable", "ShareGift.walletName")
  }

  internal enum Staking {
    /// + Select Baker
    internal static let add = L10n.tr("Localizable", "Staking.add")
    /// Free Space
    internal static let cellFreeSpaceHeader = L10n.tr("Localizable", "Staking.cellFreeSpaceHeader")
    /// Change
    internal static let changeValidator = L10n.tr("Localizable", "Staking.changeValidator")
    /// Delegate your Tezos account to a validator to earn a reward while keeping full security and control of your coins.
    internal static let descriptionTezos = L10n.tr("Localizable", "Staking.descriptionTezos")
    /// Fee:
    internal static let feeHeader = L10n.tr("Localizable", "Staking.feeHeader")
    /// Transaction pending...
    internal static let pendingTransaction = L10n.tr("Localizable", "Staking.pendingTransaction")
    /// Remove
    internal static let remove = L10n.tr("Localizable", "Staking.remove")
    /// Est. ROI
    internal static let roiHeader = L10n.tr("Localizable", "Staking.roiHeader")
    /// Select XTZ Delegate
    internal static let selectBakerTitle = L10n.tr("Localizable", "Staking.selectBakerTitle")
    /// Stake
    internal static let stake = L10n.tr("Localizable", "Staking.stake")
    /// ACTIVE
    internal static let stakingActiveFlag = L10n.tr("Localizable", "Staking.stakingActiveFlag")
    /// INACTIVE
    internal static let stakingInactiveFlag = L10n.tr("Localizable", "Staking.stakingInactiveFlag")
    /// PENDING
    internal static let stakingPendingFlag = L10n.tr("Localizable", "Staking.stakingPendingFlag")
    /// Staking
    internal static let stakingTitle = L10n.tr("Localizable", "Staking.stakingTitle")
    /// staking to %1$s
    internal static func stakingTo(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Staking.stakingTo", p1)
    }
    /// Pending
    internal static let statusPending = L10n.tr("Localizable", "Staking.statusPending")
    /// Staked!
    internal static let statusStaked = L10n.tr("Localizable", "Staking.statusStaked")
    /// Earn money while holding
    internal static let subTitle = L10n.tr("Localizable", "Staking.subTitle")
    /// Tezos & Dune
    internal static let tezosDune = L10n.tr("Localizable", "Staking.tezosDune")
    /// Multiasset Pool
    internal static let tezosMultiasset = L10n.tr("Localizable", "Staking.tezosMultiasset")
    /// Tezos-only
    internal static let tezosOnly = L10n.tr("Localizable", "Staking.tezosOnly")
    /// Stake %1$s
    internal static func title(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Staking.title", p1)
    }
    /// Unstake
    internal static let unstake = L10n.tr("Localizable", "Staking.unstake")
    /// Enter Validator Address
    internal static let validatorHint = L10n.tr("Localizable", "Staking.validatorHint")
  }

  internal enum StartPaperPhrase {
    /// Write Down Recovery Phrase Again
    internal static let againButtonTitle = L10n.tr("Localizable", "StartPaperPhrase.againButtonTitle")
    /// Your recovery phrase is the only way to restore your Fabriik if your phone is lost, stolen, broken, or upgraded.
    /// 
    /// We will show you a list of words to write down on a piece of paper and keep safe.
    internal static let body = L10n.tr("Localizable", "StartPaperPhrase.body")
    /// Write Down Recovery Phrase
    internal static let buttonTitle = L10n.tr("Localizable", "StartPaperPhrase.buttonTitle")
    /// Last written down on
    ///  %1$@
    internal static func date(_ p1: Any) -> String {
      return L10n.tr("Localizable", "StartPaperPhrase.date", String(describing: p1))
    }
    internal enum Body {
      /// Your recovery phrase is the only way to restore your Fabriik if your phone is lost, stolen, broken, or upgraded.
      /// 
      /// Your recovery phrase is also required if you change the security settings on your device.
      /// 
      /// We will show you a list of words to write down on a piece of paper and keep safe.
      internal static let android = L10n.tr("Localizable", "StartPaperPhrase.Body.Android")
    }
  }

  internal enum StartViewController {
    /// Create New Wallet
    internal static let createButton = L10n.tr("Localizable", "StartViewController.createButton")
    /// Moving money forward.
    internal static let message = L10n.tr("Localizable", "StartViewController.message")
    /// Recover Wallet
    internal static let recoverButton = L10n.tr("Localizable", "StartViewController.recoverButton")
  }

  internal enum SupportForm {
    /// We would love your feedback
    internal static let feedbackAppreciated = L10n.tr("Localizable", "SupportForm.feedbackAppreciated")
    /// Help us improve
    internal static let helpUsImprove = L10n.tr("Localizable", "SupportForm.helpUsImprove")
    /// Not now
    internal static let notNow = L10n.tr("Localizable", "SupportForm.notNow")
    /// Please describe your experience
    internal static let pleaseDescribe = L10n.tr("Localizable", "SupportForm.pleaseDescribe")
  }

  internal enum Symbols {
    /// u{1F512}
    internal static let lock = L10n.tr("Localizable", "Symbols.lock")
    /// u{2009}
    internal static let narrowSpace = L10n.tr("Localizable", "Symbols.narrowSpace")
  }

  internal enum SyncingView {
    /// Activity
    internal static let activity = L10n.tr("Localizable", "SyncingView.activity")
    /// Connecting
    internal static let connecting = L10n.tr("Localizable", "SyncingView.connecting")
    /// Sync Failed
    internal static let failed = L10n.tr("Localizable", "SyncingView.failed")
    /// Syncing
    internal static let header = L10n.tr("Localizable", "SyncingView.header")
    /// Retry
    internal static let retry = L10n.tr("Localizable", "SyncingView.retry")
    /// Synced through %1$@
    internal static func syncedThrough(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SyncingView.syncedThrough", String(describing: p1))
    }
    /// Syncing
    internal static let syncing = L10n.tr("Localizable", "SyncingView.syncing")
  }

  internal enum TimeSince {
    /// %1$@ d
    internal static func days(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TimeSince.days", String(describing: p1))
    }
    /// %1$@ h
    internal static func hours(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TimeSince.hours", String(describing: p1))
    }
    /// %1$@ m
    internal static func minutes(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TimeSince.minutes", String(describing: p1))
    }
    /// %1$@ s
    internal static func seconds(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TimeSince.seconds", String(describing: p1))
    }
  }

  internal enum TokenList {
    /// Add
    internal static let add = L10n.tr("Localizable", "TokenList.add")
    /// Add Assets
    internal static let addTitle = L10n.tr("Localizable", "TokenList.addTitle")
    /// Hide
    internal static let hide = L10n.tr("Localizable", "TokenList.hide")
    /// Manage Assets
    internal static let manageTitle = L10n.tr("Localizable", "TokenList.manageTitle")
    /// Remove
    internal static let remove = L10n.tr("Localizable", "TokenList.remove")
    /// Show
    internal static let show = L10n.tr("Localizable", "TokenList.show")
  }

  internal enum TouchIdSettings {
    /// You can customize your Touch ID spending limit from the %1$@.
    internal static func customizeText(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TouchIdSettings.customizeText", String(describing: p1))
    }
    /// Use Touch ID to unlock your Fabriik app and send money.
    internal static let explanatoryText = L10n.tr("Localizable", "TouchIdSettings.explanatoryText")
    /// Use your fingerprint to unlock your Fabriik and send money up to a set limit.
    internal static let label = L10n.tr("Localizable", "TouchIdSettings.label")
    /// Touch ID Spending Limit Screen
    internal static let linkText = L10n.tr("Localizable", "TouchIdSettings.linkText")
    /// Spending limit: %1$@ (%2$@)
    internal static func spendingLimit(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "TouchIdSettings.spendingLimit", String(describing: p1), String(describing: p2))
    }
    /// Enable Touch ID for Fabriik
    internal static let switchLabel = L10n.tr("Localizable", "TouchIdSettings.switchLabel")
    /// Touch ID
    internal static let title = L10n.tr("Localizable", "TouchIdSettings.title")
    /// Enable Touch ID to send money
    internal static let transactionsTitleText = L10n.tr("Localizable", "TouchIdSettings.transactionsTitleText")
    /// You have not set up Touch ID on this device. Go to Settings->Touch ID & Passcode to set it up now.
    internal static let unavailableAlertMessage = L10n.tr("Localizable", "TouchIdSettings.unavailableAlertMessage")
    /// Touch ID Not Set Up
    internal static let unavailableAlertTitle = L10n.tr("Localizable", "TouchIdSettings.unavailableAlertTitle")
    /// Enable Touch ID to unlock Fabriik
    internal static let unlockTitleText = L10n.tr("Localizable", "TouchIdSettings.unlockTitleText")
    internal enum CustomizeText {
      /// You can customize your Fingerprint Authentication Spending Limit from the Fingerprint Authorization Spending Limit screen
      internal static let android = L10n.tr("Localizable", "TouchIdSettings.customizeText.android")
    }
    internal enum DisabledWarning {
      internal enum Body {
        /// You have not enabled fingerprint authentication on this device. Go to Settings -> Security to set up fingerprint authentication.
        internal static let android = L10n.tr("Localizable", "TouchIdSettings.disabledWarning.body.android")
      }
      internal enum Title {
        /// Fingerprint Authentication Not Enabled
        internal static let android = L10n.tr("Localizable", "TouchIdSettings.disabledWarning.title.android")
      }
    }
    internal enum SwitchLabel {
      /// Enable Fingerprint Authentication
      internal static let android = L10n.tr("Localizable", "TouchIdSettings.switchLabel.android")
    }
    internal enum Title {
      /// Fingerprint Authentication
      internal static let android = L10n.tr("Localizable", "TouchIdSettings.title.android")
    }
  }

  internal enum TouchIdSpendingLimit {
    /// You will be asked to enter your 6-digit PIN to send any transaction over your spending limit, and every 48 hours since the last time you entered your 6-digit PIN.
    internal static let body = L10n.tr("Localizable", "TouchIdSpendingLimit.body")
    /// Touch ID Spending Limit
    internal static let title = L10n.tr("Localizable", "TouchIdSpendingLimit.title")
    internal enum Title {
      /// Fingerprint Authorization Spending Limit
      internal static let android = L10n.tr("Localizable", "TouchIdSpendingLimit.title.android")
    }
  }

  internal enum Transaction {
    /// Available to Spend
    internal static let available = L10n.tr("Localizable", "Transaction.available")
    /// Complete
    internal static let complete = L10n.tr("Localizable", "Transaction.complete")
    /// In Progress
    internal static let confirming = L10n.tr("Localizable", "Transaction.confirming")
    /// Ending balance: %1$@
    internal static func ending(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.ending", String(describing: p1))
    }
    /// Exchange rate when received:
    internal static let exchangeOnDayReceived = L10n.tr("Localizable", "Transaction.exchangeOnDayReceived")
    /// Exchange rate when sent:
    internal static let exchangeOnDaySent = L10n.tr("Localizable", "Transaction.exchangeOnDaySent")
    /// Failed
    internal static let failed = L10n.tr("Localizable", "Transaction.failed")
    /// (%1$@ fee)
    internal static func fee(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.fee", String(describing: p1))
    }
    /// INVALID
    internal static let invalid = L10n.tr("Localizable", "Transaction.invalid")
    /// just now
    internal static let justNow = L10n.tr("Localizable", "Transaction.justNow")
    /// Pending
    internal static let pending = L10n.tr("Localizable", "Transaction.pending")
    /// In progress: %1$@
    internal static func receivedStatus(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.receivedStatus", String(describing: p1))
    }
    /// In progress: %1$@
    internal static func sendingStatus(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.sendingStatus", String(describing: p1))
    }
    /// sending to %1$@
    internal static func sendingTo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.sendingTo", String(describing: p1))
    }
    /// sent to %1$@
    internal static func sentTo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.sentTo", String(describing: p1))
    }
    /// staking to %1$s
    internal static func stakingTo(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Transaction.stakingTo", p1)
    }
    /// Starting balance: %1$@
    internal static func starting(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.starting", String(describing: p1))
    }
    /// Fee for token transfer: %1$@
    internal static func tokenTransfer(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Transaction.tokenTransfer", String(describing: p1))
    }
    /// to %1$s
    internal static func toRecipient(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "Transaction.toRecipient", p1)
    }
    /// Waiting to be confirmed. Some merchants require confirmation to complete a transaction. Estimated time: 1-2 hours.
    internal static let waiting = L10n.tr("Localizable", "Transaction.waiting")
  }

  internal enum TransactionDetails {
    /// account
    internal static let account = L10n.tr("Localizable", "TransactionDetails.account")
    /// From
    internal static let addressFromHeader = L10n.tr("Localizable", "TransactionDetails.addressFromHeader")
    /// To
    internal static let addressToHeader = L10n.tr("Localizable", "TransactionDetails.addressToHeader")
    /// Via
    internal static let addressViaHeader = L10n.tr("Localizable", "TransactionDetails.addressViaHeader")
    /// Amount
    internal static let amountHeader = L10n.tr("Localizable", "TransactionDetails.amountHeader")
    /// %1$@ when received, %2$@ now
    internal static func amountWhenReceived(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.amountWhenReceived", String(describing: p1), String(describing: p2))
    }
    /// %1$@ when sent, %2$@ now
    internal static func amountWhenSent(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.amountWhenSent", String(describing: p1), String(describing: p2))
    }
    /// Confirmed in Block
    internal static let blockHeightLabel = L10n.tr("Localizable", "TransactionDetails.blockHeightLabel")
    /// Memo
    internal static let commentsHeader = L10n.tr("Localizable", "TransactionDetails.commentsHeader")
    /// Add memo...
    internal static let commentsPlaceholder = L10n.tr("Localizable", "TransactionDetails.commentsPlaceholder")
    /// Complete
    internal static let completeTimestampHeader = L10n.tr("Localizable", "TransactionDetails.completeTimestampHeader")
    /// Confirmations
    internal static let confirmationsLabel = L10n.tr("Localizable", "TransactionDetails.confirmationsLabel")
    /// Destination Tag
    internal static let destinationTag = L10n.tr("Localizable", "TransactionDetails.destinationTag")
    /// (empty)
    internal static let destinationTagEmptyHint = L10n.tr("Localizable", "TransactionDetails.destinationTag_EmptyHint")
    /// Your transactions will appear here.
    internal static let emptyMessage = L10n.tr("Localizable", "TransactionDetails.emptyMessage")
    /// Ending Balance
    internal static let endingBalanceHeader = L10n.tr("Localizable", "TransactionDetails.endingBalanceHeader")
    /// Exchange Rate
    internal static let exchangeRateHeader = L10n.tr("Localizable", "TransactionDetails.exchangeRateHeader")
    /// Total Fee
    internal static let feeHeader = L10n.tr("Localizable", "TransactionDetails.feeHeader")
    /// at %1$@
    internal static func from(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.from", String(describing: p1))
    }
    /// Gas Limit
    internal static let gasLimitHeader = L10n.tr("Localizable", "TransactionDetails.gasLimitHeader")
    /// Gas Price
    internal static let gasPriceHeader = L10n.tr("Localizable", "TransactionDetails.gasPriceHeader")
    /// Gift
    internal static let gift = L10n.tr("Localizable", "TransactionDetails.gift")
    /// Gifted to %1$s
    internal static func giftedTo(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "TransactionDetails.giftedTo", p1)
    }
    /// Hedera Memo
    internal static let hederaMemo = L10n.tr("Localizable", "TransactionDetails.hederaMemo")
    /// Hide Details
    internal static let hideDetails = L10n.tr("Localizable", "TransactionDetails.hideDetails")
    /// Initialized
    internal static let initializedTimestampHeader = L10n.tr("Localizable", "TransactionDetails.initializedTimestampHeader")
    /// More...
    internal static let more = L10n.tr("Localizable", "TransactionDetails.more")
    /// Moved %1$@
    internal static func moved(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.moved", String(describing: p1))
    }
    /// Moved <b>%1$@</b>
    internal static func movedAmountDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.movedAmountDescription", String(describing: p1))
    }
    /// Not Confirmed
    internal static let notConfirmedBlockHeightLabel = L10n.tr("Localizable", "TransactionDetails.notConfirmedBlockHeightLabel")
    /// Received %1$@
    internal static func received(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.received", String(describing: p1))
    }
    /// Received <b>%1$@</b>
    internal static func receivedAmountDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.receivedAmountDescription", String(describing: p1))
    }
    /// received from %1$@
    internal static func receivedFrom(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.receivedFrom", String(describing: p1))
    }
    /// received via %1$@
    internal static func receivedVia(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.receivedVia", String(describing: p1))
    }
    /// receiving from %1$@
    internal static func receivingFrom(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.receivingFrom", String(describing: p1))
    }
    /// receiving via %1$@
    internal static func receivingVia(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.receivingVia", String(describing: p1))
    }
    /// Reclaim
    internal static let reclaim = L10n.tr("Localizable", "TransactionDetails.reclaim")
    /// Resend
    internal static let resend = L10n.tr("Localizable", "TransactionDetails.resend")
    /// Sent %1$@
    internal static func sent(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.sent", String(describing: p1))
    }
    /// Sent <b>%1$@</b>
    internal static func sentAmountDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.sentAmountDescription", String(describing: p1))
    }
    /// Show Details
    internal static let showDetails = L10n.tr("Localizable", "TransactionDetails.showDetails")
    /// Starting Balance
    internal static let startingBalanceHeader = L10n.tr("Localizable", "TransactionDetails.startingBalanceHeader")
    /// Status
    internal static let statusHeader = L10n.tr("Localizable", "TransactionDetails.statusHeader")
    /// Transaction Details
    internal static let title = L10n.tr("Localizable", "TransactionDetails.title")
    /// Failed
    internal static let titleFailed = L10n.tr("Localizable", "TransactionDetails.titleFailed")
    /// Internal
    internal static let titleInternal = L10n.tr("Localizable", "TransactionDetails.titleInternal")
    /// Received
    internal static let titleReceived = L10n.tr("Localizable", "TransactionDetails.titleReceived")
    /// Receiving
    internal static let titleReceiving = L10n.tr("Localizable", "TransactionDetails.titleReceiving")
    /// Sending
    internal static let titleSending = L10n.tr("Localizable", "TransactionDetails.titleSending")
    /// Sent
    internal static let titleSent = L10n.tr("Localizable", "TransactionDetails.titleSent")
    /// to %1$@
    internal static func to(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TransactionDetails.to", String(describing: p1))
    }
    /// Total
    internal static let totalHeader = L10n.tr("Localizable", "TransactionDetails.totalHeader")
    /// Transaction ID
    internal static let txHashHeader = L10n.tr("Localizable", "TransactionDetails.txHashHeader")
  }

  internal enum TransactionDirection {
    /// Received at this Address
    internal static let address = L10n.tr("Localizable", "TransactionDirection.address")
    /// Sent to this Address
    internal static let to = L10n.tr("Localizable", "TransactionDirection.to")
  }

  internal enum UDomains {
    /// Invalid address.
    internal static let invalid = L10n.tr("Localizable", "UDomains.invalid")
  }

  internal enum URLHandling {
    /// Copy wallet addresses to clipboard?
    internal static let addressaddressListAlertMessage = L10n.tr("Localizable", "URLHandling.addressaddressListAlertMessage")
    /// Authorize to copy wallet address to clipboard
    internal static let addressList = L10n.tr("Localizable", "URLHandling.addressList")
    /// Copy Wallet Addresses
    internal static let addressListAlertTitle = L10n.tr("Localizable", "URLHandling.addressListAlertTitle")
    /// Copy
    internal static let copy = L10n.tr("Localizable", "URLHandling.copy")
  }

  internal enum UnlockScreen {
    /// Disabled until: %1$@
    internal static func disabled(_ p1: Any) -> String {
      return L10n.tr("Localizable", "UnlockScreen.disabled", String(describing: p1))
    }
    /// Unlock with FaceID
    internal static let faceIdText = L10n.tr("Localizable", "UnlockScreen.faceIdText")
    /// My Address
    internal static let myAddress = L10n.tr("Localizable", "UnlockScreen.myAddress")
    /// Reset PIN
    internal static let resetPin = L10n.tr("Localizable", "UnlockScreen.resetPin")
    /// Scan
    internal static let scan = L10n.tr("Localizable", "UnlockScreen.scan")
    /// Unlock your Fabriik.
    internal static let touchIdPrompt = L10n.tr("Localizable", "UnlockScreen.touchIdPrompt")
    /// Unlock with TouchID
    internal static let touchIdText = L10n.tr("Localizable", "UnlockScreen.touchIdText")
    /// Wallet disabled
    internal static let walletDisabled = L10n.tr("Localizable", "UnlockScreen.walletDisabled")
    /// You will need your recovery phrases to reset PIN.
    internal static let walletDisabledDescription = L10n.tr("Localizable", "UnlockScreen.walletDisabledDescription")
    /// Are you sure you would like to wipe this wallet?
    internal static let wipePrompt = L10n.tr("Localizable", "UnlockScreen.wipePrompt")
    internal enum TouchIdInstructions {
      /// Touch Sensor
      internal static let android = L10n.tr("Localizable", "UnlockScreen.touchIdInstructions.android")
    }
    internal enum TouchIdPrompt {
      /// Please unlock your Android device to continue.
      internal static let android = L10n.tr("Localizable", "UnlockScreen.touchIdPrompt.android")
    }
    internal enum TouchIdTitle {
      /// Authentication required
      internal static let android = L10n.tr("Localizable", "UnlockScreen.touchIdTitle.android")
    }
  }

  internal enum UpdatePin {
    /// Remember this PIN. If you forget it, you won't be able to access your assets.
    internal static let caption = L10n.tr("Localizable", "UpdatePin.caption")
    /// Your PIN will be used to unlock your Fabriik Wallet and send money
    internal static let createInstruction = L10n.tr("Localizable", "UpdatePin.createInstruction")
    /// Set PIN
    internal static let createTitle = L10n.tr("Localizable", "UpdatePin.createTitle")
    /// Confirm your new PIN
    internal static let createTitleConfirm = L10n.tr("Localizable", "UpdatePin.createTitleConfirm")
    /// Enter your current PIN.
    internal static let enterCurrent = L10n.tr("Localizable", "UpdatePin.enterCurrent")
    /// Enter your new PIN.
    internal static let enterNew = L10n.tr("Localizable", "UpdatePin.enterNew")
    /// Enter your PIN
    internal static let enterYourPin = L10n.tr("Localizable", "UpdatePin.enterYourPin")
    /// Re-Enter your new PIN.
    internal static let reEnterNew = L10n.tr("Localizable", "UpdatePin.reEnterNew")
    /// Secured wallet
    internal static let securedWallet = L10n.tr("Localizable", "UpdatePin.securedWallet")
    /// Set your new PIN
    internal static let setNewPinTitle = L10n.tr("Localizable", "UpdatePin.setNewPinTitle")
    /// Sorry, could not update PIN.
    internal static let setPinError = L10n.tr("Localizable", "UpdatePin.setPinError")
    /// Update PIN Error
    internal static let setPinErrorTitle = L10n.tr("Localizable", "UpdatePin.setPinErrorTitle")
    /// Update PIN
    internal static let updateTitle = L10n.tr("Localizable", "UpdatePin.updateTitle")
  }

  internal enum VerificationCode {
    /// Check your phone for the confirmation token we sent you. It may take a couple of minutes.
    internal static let actionInstructions = L10n.tr("Localizable", "VerificationCode.actionInstructions")
    /// Enter token
    internal static let actionLabel = L10n.tr("Localizable", "VerificationCode.actionLabel")
    /// Confirm
    internal static let buttonConfirm = L10n.tr("Localizable", "VerificationCode.buttonConfirm")
    /// We Texted You a Confirmation Code
    internal static let label = L10n.tr("Localizable", "VerificationCode.label")
    /// Confirmation Code
    internal static let title = L10n.tr("Localizable", "VerificationCode.title")
  }

  internal enum VerifyPin {
    /// Please enter your PIN to authorize this transaction.
    internal static let authorize = L10n.tr("Localizable", "VerifyPin.authorize")
    /// Please enter your PIN to continue.
    internal static let continueBody = L10n.tr("Localizable", "VerifyPin.continueBody")
    /// PIN Required
    internal static let title = L10n.tr("Localizable", "VerifyPin.title")
    /// Authorize this transaction
    internal static let touchIdMessage = L10n.tr("Localizable", "VerifyPin.touchIdMessage")
  }

  internal enum Wallet {
    /// 1d
    internal static let oneDay = L10n.tr("Localizable", "Wallet.one_day")
    /// 1m
    internal static let oneMonth = L10n.tr("Localizable", "Wallet.one_month")
    /// 1w
    internal static let oneWeek = L10n.tr("Localizable", "Wallet.one_week")
    /// 1y
    internal static let oneYear = L10n.tr("Localizable", "Wallet.one_year")
    /// Staking
    internal static let stakingTitle = L10n.tr("Localizable", "Wallet.stakingTitle")
    /// 3m
    internal static let threeMonths = L10n.tr("Localizable", "Wallet.three_months")
    /// 3y
    internal static let threeYears = L10n.tr("Localizable", "Wallet.three_years")
  }

  internal enum WalletConnectionSettings {
    /// Are you sure you want to turn off Fastsync?
    internal static let confirmation = L10n.tr("Localizable", "WalletConnectionSettings.confirmation")
    /// Make syncing your bitcoin wallet practically instant. Learn more about how it works here.
    internal static let explanatoryText = L10n.tr("Localizable", "WalletConnectionSettings.explanatoryText")
    /// Powered by
    internal static let footerTitle = L10n.tr("Localizable", "WalletConnectionSettings.footerTitle")
    /// Fastsync (pilot)
    internal static let header = L10n.tr("Localizable", "WalletConnectionSettings.header")
    /// here
    internal static let link = L10n.tr("Localizable", "WalletConnectionSettings.link")
    /// Connection Mode
    internal static let menuTitle = L10n.tr("Localizable", "WalletConnectionSettings.menuTitle")
    /// Turn Off
    internal static let turnOff = L10n.tr("Localizable", "WalletConnectionSettings.turnOff")
    /// Fastsync
    internal static let viewTitle = L10n.tr("Localizable", "WalletConnectionSettings.viewTitle")
  }

  internal enum Watch {
    /// Open the Fabriik iPhone app to set up your wallet.
    internal static let noWalletWarning = L10n.tr("Localizable", "Watch.noWalletWarning")
  }

  internal enum Webview {
    /// Dismiss
    internal static let dismiss = L10n.tr("Localizable", "Webview.dismiss")
    /// There was an error loading the content. Please try again.
    internal static let errorMessage = L10n.tr("Localizable", "Webview.errorMessage")
    /// Updating...
    internal static let updating = L10n.tr("Localizable", "Webview.updating")
  }

  internal enum Welcome {
    /// Breadwallet has changed its name to Fabriik, with a brand new look and some new features.
    /// 
    /// If you need help, look for the (?) in the top right of most screens.
    internal static let body = L10n.tr("Localizable", "Welcome.body")
    /// Welcome to Fabriik!
    internal static let title = L10n.tr("Localizable", "Welcome.title")
  }

  internal enum Widget {
    /// Stay up to date with your favorite crypto asset
    internal static let assetDescription = L10n.tr("Localizable", "Widget.assetDescription")
    /// Stay up to date with your favorite crypto assets
    internal static let assetListDescription = L10n.tr("Localizable", "Widget.assetListDescription")
    /// Asset list
    internal static let assetListTitle = L10n.tr("Localizable", "Widget.assetListTitle")
    /// Asset
    internal static let assetTitle = L10n.tr("Localizable", "Widget.assetTitle")
    /// Theme Background Colors
    internal static let colorSectionBackground = L10n.tr("Localizable", "Widget.colorSectionBackground")
    /// Basic Colors
    internal static let colorSectionBasic = L10n.tr("Localizable", "Widget.colorSectionBasic")
    /// Currency Colors
    internal static let colorSectionCurrency = L10n.tr("Localizable", "Widget.colorSectionCurrency")
    /// System Colors
    internal static let colorSectionSystem = L10n.tr("Localizable", "Widget.colorSectionSystem")
    /// Theme Text Colors
    internal static let colorSectionText = L10n.tr("Localizable", "Widget.colorSectionText")
    /// Enable in app
    /// preferences
    internal static let enablePortfolio = L10n.tr("Localizable", "Widget.enablePortfolio")
    /// Stay up to date with your portfolio
    internal static let portfolioDescription = L10n.tr("Localizable", "Widget.portfolioDescription")
    /// Portfolio
    /// Summary
    internal static let portfolioSummary = L10n.tr("Localizable", "Widget.portfolioSummary")
    /// Portfolio
    internal static let portfolioTitle = L10n.tr("Localizable", "Widget.portfolioTitle")
    internal enum Color {
      /// System Auto Light / Dark
      internal static let autoLightDark = L10n.tr("Localizable", "Widget.Color.autoLightDark")
      /// Black
      internal static let black = L10n.tr("Localizable", "Widget.Color.black")
      /// Blue
      internal static let blue = L10n.tr("Localizable", "Widget.Color.blue")
      /// Gray
      internal static let gray = L10n.tr("Localizable", "Widget.Color.gray")
      /// Green
      internal static let green = L10n.tr("Localizable", "Widget.Color.green")
      /// Orange
      internal static let orange = L10n.tr("Localizable", "Widget.Color.orange")
      /// Pink
      internal static let pink = L10n.tr("Localizable", "Widget.Color.pink")
      /// Primary
      internal static let primaryBackground = L10n.tr("Localizable", "Widget.Color.primaryBackground")
      /// Primary
      internal static let primaryText = L10n.tr("Localizable", "Widget.Color.primaryText")
      /// Purple
      internal static let purple = L10n.tr("Localizable", "Widget.Color.purple")
      /// Red
      internal static let red = L10n.tr("Localizable", "Widget.Color.red")
      /// Secondary
      internal static let secondaryBackground = L10n.tr("Localizable", "Widget.Color.secondaryBackground")
      /// Secondary
      internal static let secondaryText = L10n.tr("Localizable", "Widget.Color.secondaryText")
      /// Tertiary
      internal static let tertiaryBackground = L10n.tr("Localizable", "Widget.Color.tertiaryBackground")
      /// Tertiary
      internal static let tertiaryText = L10n.tr("Localizable", "Widget.Color.tertiaryText")
      /// White
      internal static let white = L10n.tr("Localizable", "Widget.Color.white")
      /// Yellow
      internal static let yellow = L10n.tr("Localizable", "Widget.Color.yellow")
    }
  }

  internal enum WipeWallet {
    /// Are you sure you want to delete this wallet?
    internal static let alertMessage = L10n.tr("Localizable", "WipeWallet.alertMessage")
    /// Wipe Wallet?
    internal static let alertTitle = L10n.tr("Localizable", "WipeWallet.alertTitle")
    /// Failed to wipe wallet.
    internal static let failedMessage = L10n.tr("Localizable", "WipeWallet.failedMessage")
    /// Failed
    internal static let failedTitle = L10n.tr("Localizable", "WipeWallet.failedTitle")
    /// Please enter your recovery phrase to wipe this wallet from your device.
    internal static let instruction = L10n.tr("Localizable", "WipeWallet.instruction")
    /// Starting or recovering another wallet allows you to access and manage a different Fabriik wallet on this device.
    internal static let startMessage = L10n.tr("Localizable", "WipeWallet.startMessage")
    /// Your current wallet will be removed from this device. If you wish to restore it in the future, you will need to enter your Recovery Phrase.
    internal static let startWarning = L10n.tr("Localizable", "WipeWallet.startWarning")
    /// Start or Recover Another Wallet
    internal static let title = L10n.tr("Localizable", "WipeWallet.title")
    /// Wipe
    internal static let wipe = L10n.tr("Localizable", "WipeWallet.wipe")
    /// Wiping...
    internal static let wiping = L10n.tr("Localizable", "WipeWallet.wiping")
  }

  internal enum WritePaperPhrase {
    /// Write down each word in order and store it in a safe place.
    internal static let instruction = L10n.tr("Localizable", "WritePaperPhrase.instruction")
    /// Next
    internal static let next = L10n.tr("Localizable", "WritePaperPhrase.next")
    /// Previous
    internal static let previous = L10n.tr("Localizable", "WritePaperPhrase.previous")
    /// %1$d of %2$d
    internal static func step(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "WritePaperPhrase.step", p1, p2)
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
