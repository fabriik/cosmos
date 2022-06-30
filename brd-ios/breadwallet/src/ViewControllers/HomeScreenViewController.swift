//
//  HomeScreenViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-11-27.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, Subscriber, Trackable {
    private let walletAuthenticator: WalletAuthenticator
    private let assetListTableView = AssetListTableView()
    private let debugLabel = UILabel(font: .customBody(size: 12.0), color: .transparentWhiteText) // debug info
    private let toolbar = UIToolbar()
    private var toolbarButtons = [UIButton]()
    private let notificationHandler = NotificationHandler()
    private let coreSystem: CoreSystem
    
    private lazy var subHeaderView: UIView = {
        let subHeaderView = UIView()
        subHeaderView.translatesAutoresizingMaskIntoConstraints = false
        subHeaderView.backgroundColor = .homeBackground
        subHeaderView.clipsToBounds = false
        
        return subHeaderView
    }()
    
    private lazy var totalAssetsTitleLabel: UILabel = {
        let totalAssetsTitleLabel = UILabel(font: Theme.caption, color: Theme.tertiaryText)
        totalAssetsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAssetsTitleLabel.text = L10n.HomeScreen.totalAssets
        
        return totalAssetsTitleLabel
    }()
    
    private lazy var totalAssetsAmountLabel: UILabel = {
        let totalAssetsAmountLabel = UILabel(font: Theme.boldTitle.withSize(Theme.FontSize.h1Title.rawValue), color: Theme.tertiaryText)
        totalAssetsAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAssetsAmountLabel.adjustsFontSizeToFitWidth = true
        totalAssetsAmountLabel.minimumScaleFactor = 0.5
        totalAssetsAmountLabel.textAlignment = .right
        totalAssetsAmountLabel.text = "0"
        
        return totalAssetsAmountLabel
    }()
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = E.isIPhone6OrSmaller ? UIImage(named: "LogoBlue") : UIImage(named: "LogoBlueWithText")
        
        return logoImageView
    }()
    
    private var shouldShowBuyAndSell: Bool {
        return (Store.state.experimentWithName(.buyAndSell)?.active ?? false) && (Store.state.defaultCurrencyCode == C.usdCurrencyCode)
    }
    
    private var buyButtonTitle: String {
        return shouldShowBuyAndSell ? L10n.HomeScreen.buyAndSell : L10n.HomeScreen.buy
    }
    
    private let buyButtonIndex = 0
    private let tradeButtonIndex = 1
    private let menuButtonIndex = 2
    
    private var buyButton: UIButton? {
        guard toolbarButtons.count == 4 else { return nil }
        return toolbarButtons[buyButtonIndex]
    }
    
    private var tradeButton: UIButton? {
        guard toolbarButtons.count == 4 else { return nil }
        return toolbarButtons[tradeButtonIndex]
    }
    
    var didSelectCurrency: ((Currency) -> Void)?
    var didTapManageWallets: (() -> Void)?
    var didTapBuy: (() -> Void)?
    var didTapTrade: (() -> Void)?
    var didTapProfile: (() -> Void)?
    var didTapProfileFromPrompt: ((VerificationStatus?) -> Void)?
    var didTapMenu: (() -> Void)?
    
    private lazy var totalAssetsNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    private lazy var pullToRefreshControl: UIRefreshControl = {
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        return pullToRefreshControl
    }()
    
    // MARK: -
    
    init(walletAuthenticator: WalletAuthenticator, coreSystem: CoreSystem) {
        self.walletAuthenticator = walletAuthenticator
        self.coreSystem = coreSystem
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        Store.unsubscribe(self)
    }
    
    @objc func reload() {
        setInitialData()
        setupSubscriptions()
        attemptShowGeneralPrompt()
        attemptShowKYCPrompt()
        
        coreSystem.refreshWallet { [weak self] in
            self?.assetListTableView.reload()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assetListTableView.didSelectCurrency = didSelectCurrency
        assetListTableView.didTapAddWallet = didTapManageWallets
        assetListTableView.didReload = { [weak self] in
            self?.pullToRefreshControl.endRefreshing()
        }
        
        addSubviews()
        addConstraints()
        setInitialData()
        setupSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            self.attemptShowGeneralPrompt()
            self.attemptShowKYCPrompt()
            
            if !Store.state.isLoginRequired {
                NotificationAuthorizer().showNotificationsOptInAlert(from: self, callback: { _ in
                    self.notificationHandler.checkForInAppNotifications()
                })
            }
        }

        updateTotalAssets()
        sendErrorsToBackend()
    }
    
    // MARK: Setup

    private func addSubviews() {
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(logoImageView)
        subHeaderView.addSubview(totalAssetsTitleLabel)
        subHeaderView.addSubview(totalAssetsAmountLabel)
        subHeaderView.addSubview(debugLabel)
        view.addSubview(promptContainerStack)
        view.addSubview(toolbar)
        
        assetListTableView.refreshControl = pullToRefreshControl
        pullToRefreshControl.layer.zPosition = assetListTableView.view.layer.zPosition - 1
    }

    private func addConstraints() {
        let headerHeight: CGFloat = 30.0
        let toolbarHeight: CGFloat = 74.0

        subHeaderView.constrain([
            subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subHeaderView.heightAnchor.constraint(equalToConstant: headerHeight) ])

        totalAssetsAmountLabel.constrain([
            totalAssetsAmountLabel.trailingAnchor.constraint(equalTo: subHeaderView.trailingAnchor, constant: -C.padding[2]),
            totalAssetsAmountLabel.centerYAnchor.constraint(equalTo: subHeaderView.topAnchor, constant: C.padding[1])])

        totalAssetsTitleLabel.constrain([
            totalAssetsTitleLabel.trailingAnchor.constraint(equalTo: totalAssetsAmountLabel.trailingAnchor),
            totalAssetsTitleLabel.bottomAnchor.constraint(equalTo: totalAssetsAmountLabel.topAnchor)])
        
        logoImageView.constrain([
            logoImageView.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: C.padding[2]),
            logoImageView.trailingAnchor.constraint(equalTo: totalAssetsAmountLabel.leadingAnchor, constant: -C.padding[1]),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: E.isIPhone6OrSmaller ? 40 : 158),
            logoImageView.centerYAnchor.constraint(equalTo: totalAssetsAmountLabel.centerYAnchor, constant: -4)])

        debugLabel.constrain([
            debugLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor),
            debugLabel.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -4.0)])
        
        promptContainerStack.constrain([
            promptContainerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            promptContainerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            promptContainerStack.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor)])
        
        addChildViewController(assetListTableView, layout: {
            assetListTableView.view.constrain([
                assetListTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTableView.view.topAnchor.constraint(equalTo: promptContainerStack.bottomAnchor),
                assetListTableView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                assetListTableView.view.bottomAnchor.constraint(equalTo: toolbar.topAnchor)])
        })
        
        toolbar.constrain([
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -C.padding[1]),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: C.padding[1]),
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight) ])
    }

    private func setInitialData() {
        title = ""
        view.backgroundColor = .homeBackground
        navigationItem.titleView = UIView()
        
        if E.isTestnet && !E.isScreenshots {
            debugLabel.text = "(Testnet)"
            debugLabel.isHidden = false
        } else if (E.isTestFlight || E.isDebug), let debugHost = UserDefaults.debugBackendHost {
            debugLabel.text = "[\(debugHost)]"
            debugLabel.isHidden = false
        } else {
            debugLabel.isHidden = true
        }
        
        setupToolbar()
        updateTotalAssets()
    }
    
    private func setupToolbar() {
        let buttons = [
            ("Home", #imageLiteral(resourceName: "home"), #selector(showHome)),
            (L10n.HomeScreen.trade, #imageLiteral(resourceName: "trade"), #selector(trade)),
            (L10n.HomeScreen.buy, #imageLiteral(resourceName: "buy"), #selector(buy)),
            ("Profile", #imageLiteral(resourceName: "user"), #selector(profile)),
            (L10n.HomeScreen.menu, #imageLiteral(resourceName: "more"), #selector(menu))].map { (title, image, selector) -> UIBarButtonItem in
                let button = UIButton.vertical(title: title, image: image)
                button.tintColor = .gray1
                button.addTarget(self, action: selector, for: .touchUpInside)
                return UIBarButtonItem(customView: button)
            }
        
        let paddingWidth = C.padding[2]
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarButtons = []
        toolbar.items = [flexibleSpace, buttons[0],
                         flexibleSpace, buttons[1],
                         flexibleSpace, buttons[2],
                         flexibleSpace, buttons[3],
                         flexibleSpace, buttons[4],
                         flexibleSpace
        ]
        
        let buttonWidth = (view.bounds.width - (paddingWidth * CGFloat(buttons.count + 1))) / CGFloat(buttons.count)
        let buttonHeight = CGFloat(44.0)
        buttons.forEach {
            $0.customView?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
            
            // Stash the UIButton's wrapped by the toolbar items in case we need add a badge later.
            if let button = $0.customView as? UIButton {
                self.toolbarButtons.append(button)
            }
        }
        buttons.first?.customView?.tintColor = LightColors.primary
        
        toolbar.isTranslucent = false
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.gray1.cgColor
        toolbar.barTintColor = .homeBackground
    }
    
    private func setupSubscriptions() {
        Store.unsubscribe(self)
        
        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.wallets.values.map { $0.currency }.forEach { currency in
                result = result || oldState[currency]?.balance != newState[currency]?.balance
                result = result || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
            }
            return result
        },
                        callback: { _ in
                            self.updateTotalAssets()
                            self.updateAmountsForWidgets()
        })
        
        // prompts
        Store.subscribe(self, name: .didUpgradePin, callback: { _ in
            if self.generalPromptView.type == .upgradePin {
                self.generalPromptView.isHidden = true
            }
        })
        Store.subscribe(self, name: .didWritePaperKey, callback: { _ in
            if self.generalPromptView.type == .paperKey {
                self.generalPromptView.isHidden = true
            }
        })
        
        Store.subscribe(self, selector: {
            return ($0.experiments ?? nil) != ($1.experiments ?? nil)
        }, callback: { _ in
            // Do a full reload of the toolbar so it's laid out correctly with updated button titles.
            self.setupToolbar()
            self.saveEvent("experiment.buySellMenuButton", attributes: ["show": self.shouldShowBuyAndSell ? "true" : "false"])
        })
        
        Store.subscribe(self, selector: {
            $0.wallets.count != $1.wallets.count
        }, callback: { _ in
            self.updateTotalAssets()
            self.updateAmountsForWidgets()
        })
    }
    
    private func updateTotalAssets() {
        let fiatTotal: Decimal = Store.state.wallets.values.map {
            guard let balance = $0.balance,
                let rate = $0.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                rate: rate)
            return amount.fiatValue
        }.reduce(0.0, +)
        
        let localeComponents = [NSLocale.Key.currencyCode.rawValue: UserDefaults.defaultCurrencyCode]
        let localeIdentifier = Locale.identifier(fromComponents: localeComponents)
        totalAssetsNumberFormatter.locale = Locale(identifier: localeIdentifier)
        totalAssetsNumberFormatter.currencySymbol = Store.state.orderedWallets.first?.currentRate?.currencySymbol ?? ""
        
        totalAssetsAmountLabel.text = totalAssetsNumberFormatter.string(from: fiatTotal as NSDecimalNumber)
    }
    
    private func updateAmountsForWidgets() {
        let info: [CurrencyId: Double] = Store.state.wallets
            .map { ($0, $1) }
            .reduce(into: [CurrencyId: Double]()) {
                if let balance = $1.1.balance {
                    let unit = $1.1.currency.defaultUnit
                    $0[$1.0] = balance.cryptoAmount.double(as: unit) ?? 0
                }
            }

        coreSystem.widgetDataShareService.updatePortfolio(info: info)
        coreSystem.widgetDataShareService.quoteCurrencyCode = Store.state.defaultCurrencyCode
    }
    
    // MARK: Actions
    
    @objc private func showHome() {}
    
    @objc private func buy() {
        saveEvent("currency.didTapBuyBitcoin", attributes: [ "buyAndSell": shouldShowBuyAndSell ? "true" : "false" ])
        didTapBuy?()
    }
    
    @objc private func trade() {
        saveEvent("currency.didTapTrade", attributes: [:])
        didTapTrade?()
    }
    
    @objc private func profile() {
        didTapProfile?()
    }
    
    @objc private func menu() { didTapMenu?() }
    
    // MARK: - Prompt
    
    var shouldShowGeneralPrompt: Bool {
        //Don't show any prompts on the first couple launches
        guard UserDefaults.appLaunchCount > 2 else { return false }
        
        // On the initial display we need to load the wallets in the asset list table view first.
        // There's already a lot going on, so don't show the home-screen prompts right away.
        return !Store.state.wallets.isEmpty
    }
    
    var shouldShowKYCPrompt: Bool {
        return UserDefaults.hasShownKYCVerifyPrompt == false
    }
    
    private lazy var promptContainerStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fill
        return view
    }()
    
    private var kycStatusPromptView = FEInfoView()
    private var generalPromptView = PromptView()
    
    private func attemptShowGeneralPrompt() {
//        guard shouldShowGeneralPrompt else { return }
        
        guard let nextPrompt = PromptFactory.nextPrompt(walletAuthenticator: walletAuthenticator),
              promptContainerStack.arrangedSubviews.contains(where: { $0 is PromptView }) == false else { return }
        
        generalPromptView = PromptFactory.createPromptView(prompt: nextPrompt, presenter: self)
        generalPromptView.isHidden = false
        generalPromptView.alpha = 0.0
        promptContainerStack.addArrangedSubview(generalPromptView)
        promptContainerStack.layoutIfNeeded()
        
        saveEvent("prompt.\(nextPrompt.name).displayed")
        nextPrompt.didPrompt()
        
        generalPromptView.dismissButton.tap = { [unowned self] in
            self.saveEvent("prompt.\(nextPrompt.name).dismissed")
            
            self.hidePromptElement(prompt: self.generalPromptView)
        }
        
        if !generalPromptView.shouldHandleTap {
            generalPromptView.continueButton.tap = { [unowned self] in
                if let trigger = nextPrompt.trigger {
                    Store.trigger(name: trigger)
                }
                self.saveEvent("prompt.\(nextPrompt.name).trigger")
                
                self.hidePromptElement(prompt: self.generalPromptView)
            }
        }
        
        layoutPrompts(prompt: generalPromptView)
    }
    
    private func attemptShowKYCPrompt() {
//        guard shouldShowKYCPrompt else { return }
        
        ProfileWorker().execute { [weak self] result in
            switch result {
            case .success(let data):
                self?.setupKYCPrompt(data: data, error: nil)
                
            case .failure(let error):
                self?.setupKYCPrompt(data: nil, error: error)
            }
        }
    }
    
    private func setupKYCPrompt(data: Profile?, error: Error?) {
        let newPrompt = kycStatusPromptView
        
        guard promptContainerStack.arrangedSubviews.contains(where: { $0 is FEInfoView }) == false else { return }
        
        newPrompt.isHidden = false
        newPrompt.alpha = 0.0
        
        let item = ProfileModels.Item(title: data?.email ?? "", image: "earth", status: data?.status ?? .none)
        
        let status = item.status
        let infoView: InfoViewModel = Presets.VerificationInfoView.nonePrompt
        let infoConfig: InfoViewConfiguration = Presets.InfoView.verification
        
        guard status == VerificationStatus.none || status == VerificationStatus.email || error != nil else { return }
        
        newPrompt.configure(with: infoConfig)
        newPrompt.setup(with: infoView)
        
        newPrompt.setupCustomMargins(all: .large)
        
        newPrompt.headerButtonCallback = { [weak self] in
            self?.hidePromptElement(prompt: self?.kycStatusPromptView)
        }
        
        newPrompt.trailingButtonCallback = { [weak self] in
            self?.hidePromptElement(prompt: self?.kycStatusPromptView)
            
            self?.didTapProfileFromPrompt?(status)
        }
        
        promptContainerStack.addArrangedSubview(newPrompt)
        promptContainerStack.layoutIfNeeded()
        
        UserDefaults.hasShownKYCVerifyPrompt = true
        
        layoutPrompts(prompt: kycStatusPromptView)
    }
    
    private func hidePromptElement(prompt: UIView?) {
        UIView.animate(withDuration: Presets.Animation.duration, delay: 0, options: .curveLinear) { [weak self] in
            prompt?.transform = .init(translationX: UIScreen.main.bounds.width, y: 0)
            prompt?.alpha = 0
            prompt?.isHidden = true
            
            self?.promptContainerStack.layoutIfNeeded()
        }
    }
    
    private func layoutPrompts(prompt: UIView?) {
        UIView.animate(withDuration: Presets.Animation.duration, delay: 0, options: .curveLinear) { [weak self] in
            prompt?.alpha = 1.0
            self?.promptContainerStack.layoutIfNeeded()
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: -

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func sendErrorsToBackend() {
        // Only syncs errors on TF buidls
        guard let errors = UserDefaults.errors,
              !errors.isEmpty
        else { return }
        
        Backend.apiClient.sendErrors(messages: errors) { success in
            guard success else { return }
            UserDefaults.errors = nil
        }
    }
}
