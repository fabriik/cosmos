//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayFillData(viewModel: SwapMain.FillData.ViewModel)
}

class SwapMainViewController: UIViewController, SwapMainDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: SwapMainBusinessLogic?
    var router: (NSObjectProtocol & SwapMainRoutingLogic)?
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = SwapMainInteractor()
        let presenter = SwapMainPresenter()
        let router = SwapMainRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: - Properties
    
    enum Section {
        case conversion
    }
    
    private let sections: [Section] = [
        .conversion
    ]
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setupDefault()
        tableView.indicatorStyle = .white
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    private lazy var nextButtonContainerView: UIView = {
        var nextButtonContainerView = UIView()
        nextButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        nextButtonContainerView.backgroundColor = UIColor(red: 38.0/255.0, green: 21.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        // TODO: Move colors to constants
        
        var historyButton = SimpleButton()
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setup(as: .swapEnabled, title: "NEXT")
        
        historyButton.didTap = { [weak self] in
            // TODO: Implement when we figure out what it looks like.
//            self?.router?.showConversationCompletion()
        }
        
        nextButtonContainerView.addSubview(historyButton)
        historyButton.constrainToCenter()
        historyButton.topAnchor.constraint(equalTo: nextButtonContainerView.topAnchor, constant: 16).isActive = true
        historyButton.bottomAnchor.constraint(equalTo: nextButtonContainerView.bottomAnchor, constant: -32).isActive = true
        historyButton.leadingAnchor.constraint(equalTo: nextButtonContainerView.leadingAnchor, constant: 16).isActive = true
        historyButton.trailingAnchor.constraint(equalTo: nextButtonContainerView.trailingAnchor, constant: -16).isActive = true
        
        return nextButtonContainerView
    }()
    
    private lazy var pinPad: PinPadViewController = {
        return PinPadViewController(style: .white,
                                    keyboardType: .decimalPad,
                                    maxDigits: 0,
                                    shouldShowBiometrics: false)
    }()
    
    private let pinPadBackground = UIView(color: .almostBlack)
    
    private var currencies: [SwapPickCurrency.GetCurrencyList.Currency] = []
    
    var swapType: SwapPickCurrency.SwapType = .from
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = SwapPickCurrencyViewController()
        let navController = SwapNavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
        
        tableView.register(CellWrapperView<SwapConversionView>.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(pinPadBackground)
        view.addSubview(nextButtonContainerView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: pinPadBackground.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        pinPadBackground.constrain([
            pinPadBackground.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            pinPadBackground.bottomAnchor.constraint(equalTo: nextButtonContainerView.topAnchor),
            pinPadBackground.widthAnchor.constraint(equalToConstant: floor(UIScreen.main.safeWidth/3.0)*3.0),
            pinPadBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinPadBackground.heightAnchor.constraint(equalToConstant: pinPad.height)
        ])
        
        addChild(pinPad)
        pinPadBackground.addSubview(pinPad.view)
        pinPad.view.constrain(toSuperviewEdges: nil)
        pinPad.didMove(toParent: self)
        
        nextButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        nextButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nextButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nextButtonContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // TODO: Move to the constants.
        view.backgroundColor = UIColor(red: 51.0/255.0, green: 32.0/255.0, blue: 69.0/255.0, alpha: 1.0)
        
        pinPad.ouputDidUpdate = { [weak self] amount in
            self?.interactor?.executeFillData(request: .init(sendAmount: amount))
        }
        
        // TODO: have a base class.
        localize()
        fetch()
    }
    
    func localize() {}
    
    func fetch() {}
    
    func displayFillData(viewModel: SwapMain.FillData.ViewModel) {
        guard let index = sections.firstIndex(of: .conversion) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<SwapConversionView> else { return }
        
        cell.setup { view in
            view.setup(with: .init(sendAmount: viewModel.sendAmount,
                                   receiveAmount: nil,
                                   sendCurrencyIcon: nil,
                                   sendCurrencyName: nil,
                                   receiveCurrencyIcon: nil,
                                   receiveCurrencyName: nil))
        }
    }
    
    // MARK: View controller functions
    
    func displayError(viewModel: GenericModels.Error.ViewModel) {
        LoadingView.hide()
        
        let alert = UIAlertController(style: .alert, message: viewModel.error)
        alert.addAction(title: "OK", style: .cancel)
        alert.show(on: self)
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .conversion:
            return getSwapConversionCell(indexPath)
            
        }
    }
    
    func getSwapConversionCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<SwapConversionView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        return cell
    }
}
