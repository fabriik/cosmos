//
//  EnterPhraseViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-23.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

enum PhraseEntryReason {
    case setSeed(LoginCompletionHandler)
    case validateForResettingPin(EnterPhraseCallback)
    case validateForWipingWallet(() -> Void)
}

typealias EnterPhraseCallback = (String) -> Void

class EnterPhraseViewController: UIViewController, UIScrollViewDelegate, Trackable {

    init(keyMaster: KeyMaster, reason: PhraseEntryReason) {
        self.keyMaster = keyMaster
        self.enterPhrase = EnterPhraseCollectionViewController(keyMaster: keyMaster)
        self.faq = UIButton.buildFaqButton(articleId: ArticleIds.recoverWallet, position: .right)
        self.reason = reason
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Private
    private let keyMaster: KeyMaster
    private let reason: PhraseEntryReason
    private let enterPhrase: EnterPhraseCollectionViewController
    private let errorLabel = UILabel.wrapping(font: Theme.caption, color: Theme.error)
    private let heading = UILabel.wrapping(font: Theme.h2Title, color: Theme.primaryText)
    private let subheading = UILabel.wrapping(font: Theme.body1, color: Theme.secondaryText)
    private let faq: UIButton
    private let scrollView = UIScrollView()
    private let container = UIView()

    private let headingLeftRightMargins: CGFloat = E.isSmallScreen ? 24 : 54
    
    lazy var contactSupportButton: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: 1,
        NSAttributedString.Key.font: Fonts.Body.two,
        NSAttributedString.Key.foregroundColor: LightColors.Link.one]

        let attributedString = NSMutableAttributedString(string: "Contact support", attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(contactSupportTapped), for: .touchUpInside)
        
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.UnlockScreen.resetPin
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: faq)
        navigationController?.navigationBar.tintColor = Theme.blueBackground
        
        setUpHeadings()
        addSubviews()
        addConstraints()
        setInitialData()
        showBackButton()
    }
    
    func showBackButton() {
        let back = UIBarButtonItem(image: UIImage(named: "BackArrowWhite"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(onBackButton))
        back.tintColor = Theme.blueBackground
        navigationItem.leftBarButtonItem = back
    }
    
    @objc func onBackButton() {
        guard navigationController?.viewControllers.first == self else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        navigationController?.dismiss(animated: true)
    }
    
    private func setUpHeadings() {
        [heading, subheading].forEach({
            $0.textAlignment = .center
        })
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(container)
        container.addSubview(heading)
        container.addSubview(subheading)
        container.addSubview(contactSupportButton)
        container.addSubview(errorLabel)

        addChild(enterPhrase)
        container.addSubview(enterPhrase.view)
        enterPhrase.didMove(toParent: self)
    }

    private func addConstraints() {
        scrollView.constrain([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])
        container.constrain(toSuperviewEdges: nil)
        container.constrain([
            container.widthAnchor.constraint(equalTo: view.widthAnchor) ])
        heading.constrain([
            heading.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[3]),
            heading.leftAnchor.constraint(equalTo: container.leftAnchor, constant: headingLeftRightMargins),
            heading.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -headingLeftRightMargins)
            ])
        subheading.constrain([
            subheading.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: C.padding[2]),
            subheading.leftAnchor.constraint(equalTo: container.leftAnchor, constant: headingLeftRightMargins),
            subheading.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -headingLeftRightMargins)
            ])
        
        let enterPhraseMargin: CGFloat = E.isSmallScreen ? (C.padding[2] * 0.75) : C.padding[2]
        
        enterPhrase.view.constrain([
            enterPhrase.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: enterPhraseMargin),
            enterPhrase.view.topAnchor.constraint(equalTo: subheading.bottomAnchor, constant: C.padding[4]),
            enterPhrase.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -enterPhraseMargin),
            enterPhrase.view.heightAnchor.constraint(equalToConstant: enterPhrase.height)])
        
        contactSupportButton.constrain([
            contactSupportButton.topAnchor.constraint(equalTo: enterPhrase.view.bottomAnchor, constant: -Margins.small.rawValue),
            contactSupportButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Margins.extraHuge.rawValue),
            contactSupportButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Margins.large.rawValue)
        ])
        
        errorLabel.constrain([
            errorLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[2]),
            errorLabel.topAnchor.constraint(equalTo: enterPhrase.view.bottomAnchor, constant: 12),
            errorLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[4]),
            errorLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -C.padding[2] )
            ])
    }

    private func setInitialData() {
        view.backgroundColor = .darkBackground
        errorLabel.text = L10n.RecoverWallet.invalid
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        enterPhrase.didFinishPhraseEntry = { [weak self] phrase in
            self?.validatePhrase(phrase)
        }

        switch reason {
        case .setSeed:
            saveEvent("enterPhrase.setSeed")
            heading.text = L10n.RecoveryKeyFlow.recoveryYourWallet
            subheading.text = L10n.RecoveryKeyFlow.recoveryYourWalletSubtitle
        case .validateForResettingPin:
            saveEvent("enterPhrase.resettingPin")
            heading.text = L10n.RecoveryKeyFlow.enterRecoveryKey
            subheading.text = L10n.RecoveryKeyFlow.resetPINInstruction
            faq.tap = {
                self.faqButtonPressed()
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: faq)
        case .validateForWipingWallet:
            saveEvent("enterPhrase.wipeWallet")
            heading.text = L10n.RecoveryKeyFlow.enterRecoveryKey
            subheading.text = L10n.RecoveryKeyFlow.enterRecoveryKeySubtitle
        }

        scrollView.delegate = self
    }
    
    @objc private func contactSupportTapped() {
        guard let url = URL(string: C.supportLink) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: "Support"))
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        
        present(navController, animated: true)
    }
    
    func faqButtonPressed() {
        // TODO: localize
        let text = """
                        A Recovery Phrase consists of 12 randomly generated words. The app creates the Recovery Phrase for you automatically when you start a new wallet.
                        The Recovery Phrase is critically important and should be written down and stored in a safe location.
                        In the event of phone theft, destruction, or loss, the Recovery Phrase can be used to load your wallet onto a new phone.
                        The key is also required when upgrading your current phone to a new one.
                        """
        
        let model = PopupViewModel(title: .text("What is “Recovery Phrase”?"),
                                   body: text)
        
        showInfoPopup(with: model)
    }

    private func validatePhrase(_ phrase: String) {
        guard keyMaster.isSeedPhraseValid(phrase) else {
            saveEvent("enterPhrase.invalid")
            
            showToastMessage(message: L10n.RecoverWallet.invalid)
            return
        }
        saveEvent("enterPhrase.valid")

        switch reason {
        case .setSeed(let callback):
            guard let account = self.keyMaster.setSeedPhrase(phrase) else { errorLabel.isHidden = false; return }
            //Since we know that the user had their phrase at this point,
            //this counts as a write date
            UserDefaults.writePaperPhraseDate = Date()
            Store.perform(action: LoginSuccess())
            return callback(account)
        case .validateForResettingPin(let callback):
            guard self.keyMaster.authenticate(withPhrase: phrase) else { errorLabel.isHidden = false; return }
            UserDefaults.writePaperPhraseDate = Date()
            return callback(phrase)
        case .validateForWipingWallet(let callback):
            guard self.keyMaster.authenticate(withPhrase: phrase) else { errorLabel.isHidden = false; return }
            return callback()
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        var contentInset = scrollView.contentInset
        if contentInset.bottom == 0.0 {
            contentInset.bottom = frameValue.cgRectValue.height + 44.0
        }
        scrollView.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: Notification) {
        var contentInset = scrollView.contentInset
        if contentInset.bottom > 0.0 {
            contentInset.bottom = 0.0
        }
        scrollView.contentInset = contentInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
