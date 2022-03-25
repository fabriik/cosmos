//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyDisplayLogic: AnyObject {
    // MARK: Display logic functions
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
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setupDefault()
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    lazy var searchController: UISearchController = {
        var searchController = UISearchController(searchResultsController: nil)
        
        return searchController
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        tableView.register(cell: SwapCryptoCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        view.backgroundColor = UIColor(red: 51.0/255.0, green: 32.0/255.0, blue: 69.0/255.0, alpha: 1.0)
        
        localize()
    }
    
    func localize() {
        title = "Trade Your"
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        print(text)
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
        case .cryptos:
            return UITableViewCell()
        }
    }
}
