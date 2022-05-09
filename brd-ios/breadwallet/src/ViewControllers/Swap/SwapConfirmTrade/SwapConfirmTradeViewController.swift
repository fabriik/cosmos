//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapConfirmTradeDisplayLogic: AnyObject {
    // MARK: Display logic functions
}

class SwapConfirmTradeViewController: UIViewController, SwapConfirmTradeDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: SwapConfirmTradeBusinessLogic?
    var router: (NSObjectProtocol & SwapConfirmTradeRoutingLogic)?
    
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
        let interactor = SwapConfirmTradeInteractor()
        let presenter = SwapConfirmTradePresenter()
        let router = SwapConfirmTradeRouter()
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
    
    private lazy var buyButtonContainerView: UIView = {
        var buyButtonContainerView = UIView()
        buyButtonContainerView.translatesAutoresizingMaskIntoConstraints = false        
        var buyButton = SimpleButton()
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.setup(as: .swapEnabled, title: "Buy")
        
        buyButton.didTap = { [] in
            // TODO: Implement when we figure out what it looks like.
        }
        
        buyButtonContainerView.addSubview(buyButton)
        buyButton.constrainToCenter()
        let defaultDistance: CGFloat = 16
        
        buyButton.topAnchor.constraint(equalTo: buyButtonContainerView.topAnchor, constant: defaultDistance).isActive = true
        buyButton.bottomAnchor.constraint(equalTo: buyButtonContainerView.bottomAnchor, constant: -defaultDistance).isActive = true
        buyButton.leadingAnchor.constraint(equalTo: buyButtonContainerView.leadingAnchor, constant: defaultDistance).isActive = true
        buyButton.trailingAnchor.constraint(equalTo: buyButtonContainerView.trailingAnchor, constant: -defaultDistance).isActive = true
        
        return buyButtonContainerView
    }()
    
    override func loadView() {
        super.loadView()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<SwapConfirmTradeView>.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(buyButtonContainerView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: buyButtonContainerView.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        buyButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buyButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buyButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buyButtonContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        view.backgroundColor = Theme.primaryBackground
        
        localize()
    }
    
    // MARK: - Properties
    
    enum Section {
        case confirmTrade
    }
    
    private let sections: [Section] = [
        .confirmTrade
    ]
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setupDefault()
        tableView.indicatorStyle = .white
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    func localize() {
        title = "Confirm Trade"
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
        case .confirmTrade:
            return getConfirmTradenCell(indexPath)
        }
    }
    
    func getConfirmTradenCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<SwapConfirmTradeView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        return cell
    }
}
