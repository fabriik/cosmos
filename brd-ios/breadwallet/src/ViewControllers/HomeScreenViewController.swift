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
    private let subHeaderView = UIView()
    private let debugLabel = UILabel(font: .customBody(size: 12.0), color: .transparentWhiteText) // debug info
    private let prompt = UIView()
    private var promptHiddenConstraint: NSLayoutConstraint!
    private let toolbar = UIToolbar()
    private var toolbarButtons = [UIButton]()
    private let notificationHandler = NotificationHandler()
    private let coreSystem: CoreSystem
    
    private lazy var totalAssetsTitleLabel: UILabel = {
        let totalAssetsTitleLabel = UILabel(font: Theme.caption, color: Theme.tertiaryText)
        totalAssetsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAssetsTitleLabel.text = S.HomeScreen.totalAssets
        
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
        return shouldShowBuyAndSell ? S.HomeScreen.buyAndSell : S.HomeScreen.buy
    }
    
    private let buyButtonIndex = 0
    private let tradeButtonIndex = 1
    private let menuButtonIndex = 2
    
    private var buyButton: UIButton? {
        guard toolbarButtons.count == 3 else { return nil }
        return toolbarButtons[buyButtonIndex]
    }
    
    private var tradeButton: UIButton? {
        guard toolbarButtons.count == 3 else { return nil }
        return toolbarButtons[tradeButtonIndex]
    }
    
    var didSelectCurrency: ((Currency) -> Void)?
    var didTapManageWallets: (() -> Void)?
    var didTapBuy: ((String, String) -> Void)?
    var didTapTrade: (() -> Void)?
    var didTapMenu: (() -> Void)?
    
    var okToShowPrompts: Bool {
        //Don't show any prompts on the first couple launches
        guard UserDefaults.appLaunchCount > 2 else { return false }
        
        // On the initial display we need to load the wallets in the asset list table view first.
        // There's already a lot going on, so don't show the home-screen prompts right away.
        return !Store.state.wallets.isEmpty
    }
    
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
        attemptShowPrompt()
        
        Backend.apiClient.updateBundles { [weak self] errors in
            for (n, e) in errors {
                print("Bundle \(n) ran update. err: \(String(describing: e))")
            }
            
            switch self?.walletAuthenticator.loadAccount() {
            case .success(let account):
                guard let kvStore = Backend.kvStore else { return assertionFailure() }
                
                self?.coreSystem.getCurrencyMetaData(kvStore: kvStore,
                                                     account: account, completion: { [weak self] in
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.assetListTableView.reload()
                    }
                })
                
            case .failure(let error):
                print(error)
                
            default:
                break
                
            }
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

        DispatchQueue.main.asyncAfter(deadline: .now() + promptDelay) { [unowned self] in
            self.attemptShowPrompt()
            
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
        view.addSubview(prompt)
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
        
        promptHiddenConstraint = prompt.heightAnchor.constraint(equalToConstant: 0.0)
        prompt.constrain([
            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            prompt.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor),
            promptHiddenConstraint])
        
        addChildViewController(assetListTableView, layout: {
            assetListTableView.view.constrain([
                assetListTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTableView.view.topAnchor.constraint(equalTo: prompt.bottomAnchor),
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
        view.backgroundColor = .homeBackground
        subHeaderView.backgroundColor = .homeBackground
        subHeaderView.clipsToBounds = false
        
        navigationItem.titleView = UIView()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "TransparentPixel"), for: .default)
        
        title = ""
        
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
        let buttons = [(buyButtonTitle, #imageLiteral(resourceName: "buy"), #selector(buy)),
                       (S.HomeScreen.trade, #imageLiteral(resourceName: "trade"), #selector(trade)),
                       (S.HomeScreen.menu, #imageLiteral(resourceName: "menu"), #selector(menu))].map { (title, image, selector) -> UIBarButtonItem in
                        let button = UIButton.vertical(title: title, image: image)
                        button.tintColor = .gray1
                        button.addTarget(self, action: selector, for: .touchUpInside)
                        return UIBarButtonItem(customView: button)
        }
                
        let paddingWidth = C.padding[2]
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarButtons = []
        toolbar.items = [
            flexibleSpace,
            buttons[0],
            flexibleSpace,
            buttons[1],
            flexibleSpace,
            buttons[2],
            flexibleSpace
        ]
        
        let buttonWidth = (view.bounds.width - (paddingWidth * CGFloat(buttons.count+1))) / CGFloat(buttons.count)
        let buttonHeight = CGFloat(44.0)
        buttons.forEach {
            $0.customView?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        }
        
        // Stash the UIButton's wrapped by the toolbar items in case we need add a badge later.
        buttons.forEach { (toolbarButtonItem) in
            if let button = toolbarButtonItem.customView as? UIButton {
                self.toolbarButtons.append(button)
            }
        }

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
            if self.currentPromptView?.type == .upgradePin {
                self.currentPromptView = nil
            }
        })
        Store.subscribe(self, name: .didWritePaperKey, callback: { _ in
            if self.currentPromptView?.type == .paperKey {
                self.currentPromptView = nil
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
    
    @objc private func buy() {
        // TODO: move worker out of VC
        buyButton?.isEnabled = false
        saveEvent("currency.didTapBuyBitcoin", attributes: [ "buyAndSell": shouldShowBuyAndSell ? "true" : "false" ])
        
        ExternalAPIClient.shared.send(WyreReservationRequest()) { [weak self] response in
            switch response {
            case .success(let reservation):
                guard let url = reservation.url,
                      let code = reservation.reservation else {
                    return
                }
                self?.didTapBuy?(url, code)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            self?.buyButton?.isEnabled = true
        }
        
    }
    
    @objc private func trade() {
        saveEvent("currency.didTapTrade", attributes: [:])
        didTapTrade?()
    }
    
    @objc private func menu() { didTapMenu?() }
    
    // MARK: - Prompt
    
    private let promptDelay: TimeInterval = 0.6
    
    private var currentPromptView: PromptView? {
        didSet {
            if currentPromptView != oldValue {
                var afterFadeOut: TimeInterval = 0.0
                if let oldPrompt = oldValue {
                    afterFadeOut = 0.15
                    UIView.animate(withDuration: 0.2, animations: {
                        oldValue?.alpha = 0.0
                    }, completion: { _ in
                        oldPrompt.removeFromSuperview()
                    })
                }
                
                if let newPrompt = currentPromptView {
                    newPrompt.alpha = 0.0
                    prompt.addSubview(newPrompt)
                    newPrompt.constrain(toSuperviewEdges: .zero)
                    prompt.layoutIfNeeded()
                    promptHiddenConstraint.isActive = false

                    // fade-in after fade-out and layout
                    UIView.animate(withDuration: 0.2, delay: afterFadeOut + 0.15, options: .curveEaseInOut, animations: {
                        newPrompt.alpha = 1.0
                    })
                    
                } else {
                    promptHiddenConstraint.isActive = true
                }
                
                // layout after fade-out
                UIView.animate(withDuration: 0.2, delay: afterFadeOut, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    private func attemptShowPrompt() {
        guard okToShowPrompts else { return }
        guard currentPromptView == nil else { return }
        
        if let nextPrompt = PromptFactory.nextPrompt(walletAuthenticator: walletAuthenticator) {
            self.saveEvent("prompt.\(nextPrompt.name).displayed")
            
            // didSet {} for 'currentPromptView' will display the prompt view
            currentPromptView = PromptFactory.createPromptView(prompt: nextPrompt, presenter: self)
            
            nextPrompt.didPrompt()
            
            guard let prompt = currentPromptView else { return }
            
            prompt.dismissButton.tap = { [unowned self] in
                self.saveEvent("prompt.\(nextPrompt.name).dismissed")
                self.currentPromptView = nil
            }
            
            if !prompt.shouldHandleTap {
                prompt.continueButton.tap = { [unowned self] in
                    if let trigger = nextPrompt.trigger {
                        Store.trigger(name: trigger)
                    }
                    self.saveEvent("prompt.\(nextPrompt.name).trigger")
                    self.currentPromptView = nil
                }                
            }
            
        } else {
            currentPromptView = nil
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
