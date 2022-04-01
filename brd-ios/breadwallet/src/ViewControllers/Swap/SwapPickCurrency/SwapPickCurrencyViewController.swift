//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayGetCurrencyList(viewModel: SwapPickCurrency.GetCurrencyList.ViewModel)
}

class SwapPickCurrencyViewController: UIViewController, SwapPickCurrencyDisplayLogic, UITableViewDelegate, UITableViewDataSource,
                                      UISearchResultsUpdating, UISearchBarDelegate {
    var interactor: SwapPickCurrencyBusinessLogic?
    var router: (NSObjectProtocol & SwapPickCurrencyRoutingLogic)?
    
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
        let interactor = SwapPickCurrencyInteractor()
        let presenter = SwapPickCurrencyPresenter()
        let router = SwapPickCurrencyRouter()
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
        case cryptos
    }
    
    private let sections: [Section] = [
        .cryptos
    ]
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setupDefault()
        tableView.indicatorStyle = .white
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        var searchController = UISearchController()
        searchController.searchBar.barStyle = .black
        
        return searchController
    }()
    
    private lazy var historyButtonContainerView: UIView = {
        var historyButtonContainerView = UIView()
        historyButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        historyButtonContainerView.backgroundColor = Theme.primaryBackground
        
        var historyButton = SimpleButton()
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setup(as: .swapEnabled, title: "HISTORY")
        
        historyButton.didTap = { [weak self] in
            self?.router?.showSwapHistory()
        }
        
        historyButtonContainerView.addSubview(historyButton)
        historyButton.constrainToCenter()
        historyButton.topAnchor.constraint(equalTo: historyButtonContainerView.topAnchor, constant: 16).isActive = true
        historyButton.bottomAnchor.constraint(equalTo: historyButtonContainerView.bottomAnchor, constant: -32).isActive = true
        historyButton.leadingAnchor.constraint(equalTo: historyButtonContainerView.leadingAnchor, constant: 16).isActive = true
        historyButton.trailingAnchor.constraint(equalTo: historyButtonContainerView.trailingAnchor, constant: -16).isActive = true
        
        return historyButtonContainerView
    }()
    
    private var currencies: [SwapPickCurrency.GetCurrencyList.Currency] = []
    
    var swapType: SwapPickCurrency.SwapType = .from
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        tableView.register(CellWrapperView<SwapCryptoView>.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(historyButtonContainerView)
        historyButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        historyButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        historyButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyButtonContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: historyButtonContainerView.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.backgroundColor = Theme.primaryBackground
        
        localize()
        fetch()
    }
    
    func localize() {
        title = "Swap Your"
    }
    
    func fetch() {
        interactor?.executeGetCurrencyList(request: .init())
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        
        if text.isEmpty {
            currencies.indices.forEach { currencies[$0].isVisible = true }
        } else {
            currencies.indices.forEach { currencies[$0].isVisible = currencies[$0].title.lowercased().contains(text) }
        }
        
        tableView.reloadData()
    }
    
    // MARK: View controller functions
    
    func displayGetCurrencyList(viewModel: SwapPickCurrency.GetCurrencyList.ViewModel) {
        currencies = viewModel.currencies
    }
    
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
        let filteredCurrencies = currencies.filter { $0.isVisible == true }
        return filteredCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .cryptos:
            return getSwapCryptoCell(indexPath)
            
        }
    }
    
    func getSwapCryptoCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<SwapCryptoView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            let currency = currencies[indexPath.row]
            view.setup(with: .init(image: currency.image,
                                   title: currency.title,
                                   subtitle: currency.subtitle,
                                   amount: currency.amount,
                                   conversion: currency.conversion))
        }
        
        return cell
    }
}
