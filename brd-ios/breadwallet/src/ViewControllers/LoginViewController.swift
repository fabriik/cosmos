//
//  LoginViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-19.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import LocalAuthentication
import WalletKit
import MachO

class LoginViewController: UIViewController, Subscriber, Trackable {
    enum Context {
        case initialLaunch(loginHandler: LoginCompletionHandler)
        case automaticLock
        case manualLock

        var shouldAttemptBiometricUnlock: Bool {
            switch self {
            case .manualLock:
                return false
            default:
                return true
            }
        }
    }

    init(for context: Context, keyMaster: KeyMaster, shouldDisableBiometrics: Bool) {
        self.context = context
        self.keyMaster = keyMaster
        self.disabledView = WalletDisabledView()
        self.shouldDisableBiometrics = shouldDisableBiometrics
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        Store.unsubscribe(self)
        notificationObservers.values.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Private
    private let keyMaster: KeyMaster
    private let backgroundView = UIView()
    private let pinViewContainer = UIView()
    private lazy var pinPad: PinPadViewController = {
        return PinPadViewController(style: .clear, keyboardType: .pinPad, maxDigits: 0, shouldShowBiometrics: shouldUseBiometrics)
    }()
    private lazy var pinView: PinView = {
        return PinView(style: .login, length: Store.state.pinLength)
    }()
    private let disabledView: WalletDisabledView
    private var logo = UIImageView(image: #imageLiteral(resourceName: "LogoBlue"))
    private var pinPadPottom: NSLayoutConstraint?
    private var topControlTop: NSLayoutConstraint?
    private var unlockTimer: Timer?
    private let pinPadBackground = UIView(color: .almostBlack)
    private let logoBackground = MotionGradientView()
    private var hasAttemptedToShowBiometrics = false
    private let lockedOverlay = UIVisualEffectView()
    private var isResetting = false
    private let context: Context
    private var notificationObservers = [String: NSObjectProtocol]()
    private let debugLabel = UILabel.wrapping(font: Theme.body3, color: .almostBlack)
    private let shouldDisableBiometrics: Bool
    
    var isBiometricsEnabledForUnlocking: Bool {
        return self.keyMaster.isBiometricsEnabledForUnlocking
    }
    
    lazy var header: UILabel = {
        let header = UILabel()
        header.textColor = Theme.primaryText
        header.font = Fonts.Title.four
        header.textAlignment = .center
        header.text = L10n.UpdatePin.securedWallet
        
        return header
    }()
    
    lazy var instruction: UILabel = {
        let instruction = UILabel()
        instruction.textColor = Theme.secondaryText
        instruction.font = Fonts.Body.two
        instruction.textAlignment = .center
        instruction.text = L10n.UpdatePin.enterYourPin
        
        return instruction
    }()
    
    lazy var resetPinButton: UIButton = {
        let resetPinButton = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: 1,
        NSAttributedString.Key.font: Fonts.Subtitle.two,
        NSAttributedString.Key.foregroundColor: Theme.primaryText]

        let attributedString = NSMutableAttributedString(string: L10n.RecoverWallet.headerResetPin, attributes: attributes)
        resetPinButton.setAttributedTitle(attributedString, for: .normal)
        resetPinButton.addTarget(self, action: #selector(resetPinTapped), for: .touchUpInside)
        
        return resetPinButton
    }()
    
    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        addPinPadCallbacks()
        addPinView()

        disabledView.didTapReset = { [weak self] in
            guard let `self` = self else { return }
            self.isResetting = true
            
            RecoveryKeyFlowController.enterResetPinFlow(from: self,
                                                        keyMaster: self.keyMaster,
                                                        callback: { (phrase, navController) in
                                                            let updatePin = UpdatePinViewController(keyMaster: self.keyMaster,
                                                                                                    type: .creationWithPhrase,
                                                                                                    showsBackButton: false,
                                                                                                    phrase: phrase)
                                                            
                                                            navController.pushViewController(updatePin, animated: true)
                                                            
                                                            updatePin.resetFromDisabledWillSucceed = {
                                                                self.disabledView.isHidden = true
                                                            }
                                                            
                                                            updatePin.resetFromDisabledSuccess = { pin in
                                                                if case .initialLaunch = self.context {
                                                                    guard let account = self.keyMaster.createAccount(withPin: pin) else { return assertionFailure() }
                                                                    self.authenticationSucceded(forLoginWithAccount: account)
                                                                } else {
                                                                    self.authenticationSucceded()
                                                                }
                                                            }
            })            
        }
        disabledView.didCompleteWipeGesture = { [weak self] in
            guard let `self` = self else { return }
            self.wipeFromDisabledGesture()
        }
        updateDebugLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UIApplication.shared.applicationState != .background else { return }

        if shouldUseBiometrics && !hasAttemptedToShowBiometrics && context.shouldAttemptBiometricUnlock {
            hasAttemptedToShowBiometrics = true
            biometricsTapped()
        }
        if !isResetting {
            lockIfNeeded()
        }
        
        // detect jailbreak so we can throw up an idiot warning, in viewDidLoad so it can't easily be swizzled out
        if !E.isSimulator {
            var s = stat()
            var isJailbroken = (stat("/bin/sh", &s) == 0) ? true : false
            for i in 0..<_dyld_image_count() {
                guard !isJailbroken else { break }
                // some anti-jailbreak detection tools re-sandbox apps, so do a secondary check for any MobileSubstrate dyld images
                if strstr(_dyld_get_image_name(i), "MobileSubstrate") != nil {
                    isJailbroken = true
                }
            }
            notificationObservers[UIApplication.willEnterForegroundNotification.rawValue] =
                NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
                    self?.showJailbreakWarnings(isJailbroken: isJailbroken)
            }
            showJailbreakWarnings(isJailbroken: isJailbroken)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unlockTimer?.invalidate()
    }

    private func addPinView() {
        pinViewContainer.addSubview(pinView)
        pinView.constrain([
            pinView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: pinViewContainer.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize)])
    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(pinViewContainer)
        view.addSubview(logo)
        view.addSubview(header)
        view.addSubview(instruction)
        view.addSubview(resetPinButton)
        view.addSubview(pinPadBackground)
        view.addSubview(debugLabel)
    }

    private func addConstraints() {
        backgroundView.constrain(toSuperviewEdges: nil)
        backgroundView.backgroundColor = Theme.primaryBackground
        pinViewContainer.constrain(toSuperviewEdges: nil)
        debugLabel.constrain([
            debugLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[3]),
            debugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2])
        ])
        topControlTop = logo.topAnchor.constraint(equalTo: view.topAnchor,
                                                  constant: C.Sizes.brdLogoHeight * 2 + C.Sizes.brdLogoTopMargin)
        logo.constrain([
            topControlTop,
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 104),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor)])
        
        header.constrain([
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: C.padding[3])])
        
        instruction.constrain([
            instruction.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instruction.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2])])
        
        pinPadPottom = pinPadBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        pinPadBackground.constrain([
            pinPadBackground.widthAnchor.constraint(equalToConstant: floor(UIScreen.main.safeWidth/3.0)*3.0),
            pinPadBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinPadBackground.heightAnchor.constraint(equalToConstant: pinPad.height),
            pinPadPottom])
        
        resetPinButton.constrain([
            resetPinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetPinButton.bottomAnchor.constraint(equalTo: pinPadBackground.topAnchor, constant: -C.padding[10])])
        
        addChild(pinPad)
        pinPadBackground.addSubview(pinPad.view)
        pinPad.view.constrain(toSuperviewEdges: nil)
        pinPad.didMove(toParent: self)
        
        header.isHidden = true
        instruction.isHidden = true
        resetPinButton.isHidden = true
    }
    
    @objc private func resetPinTapped() {
        isResetting = true
        
        RecoveryKeyFlowController.enterResetPinFlow(from: self,
                                                    keyMaster: self.keyMaster,
                                                    callback: { (phrase, navController) in
            let updatePin = UpdatePinViewController(keyMaster: self.keyMaster,
                                                    type: .creationWithPhrase,
                                                    showsBackButton: true,
                                                    phrase: phrase)
            
            navController.pushViewController(updatePin, animated: true)
            
            updatePin.resetFromDisabledSuccess = { pin in
                if case .initialLaunch = self.context {
                    guard let account = self.keyMaster.createAccount(withPin: pin) else { return assertionFailure() }
                    self.authenticationSucceded(forLoginWithAccount: account)
                } else {
                    self.authenticationSucceded()
                }
            }
        })
    }

    private func addPinPadCallbacks() {
        pinPad.didTapBiometrics = { [weak self] in
            self?.biometricsTapped()
        }
        pinPad.ouputDidUpdate = { [weak self] pin in
            guard let pinView = self?.pinView else { return }
            let attemptLength = pin.utf8.count
            pinView.fill(attemptLength)
            self?.pinPad.isAppendingDisabled = attemptLength < Store.state.pinLength ? false : true
            if attemptLength == Store.state.pinLength {
                self?.authenticate(withPin: pin)
            }
        }
    }

    private func authenticate(withPin pin: String) {
        guard !E.isScreenshots else { return authenticationSucceded() }
        if case .initialLaunch = context {
            guard let account = keyMaster.createAccount(withPin: pin) else { return authenticationFailed() }
            authenticationSucceded(forLoginWithAccount: account)
        } else {
            guard keyMaster.authenticate(withPin: pin) else { return authenticationFailed() }
            authenticationSucceded()
        }
    }

    private func authenticationSucceded(forLoginWithAccount account: Account? = nil) {
        saveEvent("login.success")
        let label = UILabel(font: .customBody(size: 16.0))
        label.textColor = .black
        label.alpha = 0.0
        let lock = UIImageView(image: #imageLiteral(resourceName: "unlock"))
        lock.alpha = 0.0

        view.addSubview(label)
        view.addSubview(lock)

        label.constrain([
            label.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -C.padding[1]),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor) ])
        lock.constrain([
            lock.topAnchor.constraint(equalTo: label.bottomAnchor, constant: C.padding[1]),
            lock.centerXAnchor.constraint(equalTo: label.centerXAnchor) ])
        view.layoutIfNeeded()

        UIView.spring(0.6, animations: {
            self.pinPadPottom?.constant = self.pinPad.height
            self.topControlTop?.constant = -100.0
            lock.alpha = 1.0
            label.alpha = 1.0
            self.pinView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: true, completion: {
                Store.perform(action: LoginSuccess())
                if case .initialLaunch(let loginHandler) = self.context {
                    guard let account = account else { return assertionFailure() }
                    loginHandler(account)
                }
            })
            Store.trigger(name: .showStatusBar)
        })
    }

    private func authenticationFailed() {
        saveEvent("login.failed")
        pinPad.view.isUserInteractionEnabled = false
        pinView.shake { [weak self] in
            self?.pinPad.view.isUserInteractionEnabled = true
        }
        pinPad.clear()
        DispatchQueue.main.asyncAfter(deadline: .now() + pinView.shakeDuration) {
            self.pinView.fill(0)
            self.lockIfNeeded()
        }
        updateDebugLabel()
    }

    private var shouldUseBiometrics: Bool {
        return LAContext.canUseBiometrics && !keyMaster.pinLoginRequired && isBiometricsEnabledForUnlocking && !shouldDisableBiometrics
    }

    @objc func biometricsTapped() {
        guard !isWalletDisabled else { return }
        if case .initialLaunch = context {
            keyMaster.createAccount(withBiometricsPrompt: L10n.UnlockScreen.touchIdPrompt, completion: { account in
                if let account = account {
                    self.authenticationSucceded(forLoginWithAccount: account)
                }
            })
        } else {
            keyMaster.authenticate(withBiometricsPrompt: L10n.UnlockScreen.touchIdPrompt, completion: { result in
                if result == .success {
                    self.authenticationSucceded()
                }
            })
        }
    }

    private func lockIfNeeded() {
        guard keyMaster.walletIsDisabled else {
            pinPad.view.isUserInteractionEnabled = true
            disabledView.hide { [weak self] in
                self?.disabledView.removeFromSuperview()
                self?.setNeedsStatusBarAppearanceUpdate()
            }
            return
        }
        saveEvent("login.locked")
        let disabledUntil = keyMaster.walletDisabledUntil
        let disabledUntilDate = Date(timeIntervalSince1970: disabledUntil)
        let unlockInterval = disabledUntil - Date().timeIntervalSince1970
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate(unlockInterval > C.secondsInDay ? "h:mm:ss a MMM d, yyy" : "h:mm:ss a")

        disabledView.setTimeLabel(string: L10n.UnlockScreen.disabled(df.string(from: disabledUntilDate)))

        pinPad.view.isUserInteractionEnabled = false
        unlockTimer?.invalidate()
        unlockTimer =  Timer.scheduledTimer(withTimeInterval: unlockInterval, repeats: false) { _ in
            self.saveEvent("login.unlocked")
            self.pinPad.view.isUserInteractionEnabled = true
            self.unlockTimer = nil
            self.disabledView.hide { [unowned self] in
                self.disabledView.removeFromSuperview()
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }

        let faqButton = UIButton.buildFaqButton(articleId: ArticleIds.walletDisabled, position: .right)
        faqButton.tintColor = Theme.primaryText
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: faqButton)

        if disabledView.superview == nil {
            view.addSubview(disabledView)
            setNeedsStatusBarAppearanceUpdate()
            disabledView.constrain(toSuperviewEdges: .zero)
            disabledView.show()
        }
    }

    private var isWalletDisabled: Bool {
        let now = Date().timeIntervalSince1970
        return keyMaster.walletDisabledUntil > now
    }
    
    private func showJailbreakWarnings(isJailbroken: Bool) {
        guard isJailbroken else { return }
        let alert = UIAlertController(title: L10n.JailbreakWarnings.title, message: L10n.JailbreakWarnings.messageWithBalance, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.JailbreakWarnings.ignore, style: .default, handler: { _ in
            self.saveEvent(self.makeEventName([EventContext.jailbreak.name, Event.ignore.name]))
        }))
        alert.addAction(UIAlertAction(title: L10n.JailbreakWarnings.close, style: .default, handler: { _ in
            self.saveEvent(self.makeEventName([EventContext.jailbreak.name, Event.close.name]))
            exit(0)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func updateDebugLabel() {
        guard E.isDebug else { return }
        let remaining = keyMaster.pinAttemptsRemaining
        let timestamp = keyMaster.walletDisabledUntil
        let disabledUntil = Date(timeIntervalSince1970: timestamp)
        let firstLine = "Attempts remaining: \(remaining)"
        let secondLine = "Disabled until: \(disabledUntil)"
        debugLabel.text = "\(firstLine)\n\(secondLine)"
    }
    
    private func wipeFromDisabledGesture() {
        let disabledUntil = keyMaster.walletDisabledUntil
        let unlockInterval = disabledUntil - Date().timeIntervalSince1970
        
        //If unlock time is greater than 4 hours allow wiping
        guard unlockInterval > (C.secondsInMinute * 60 * 4.0) else { return }
        let alertView = UIAlertController(title: "",
                                          message: L10n.UnlockScreen.wipePrompt, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: L10n.Button.cancel, style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: L10n.JailbreakWarnings.wipe, style: .destructive, handler: { _ in
            Store.trigger(name: .wipeWalletNoPrompt)
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
