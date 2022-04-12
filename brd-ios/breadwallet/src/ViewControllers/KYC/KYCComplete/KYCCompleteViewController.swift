// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCCompleteDisplayLogic: AnyObject {
    // MARK: Display logic functions
}

class KYCCompleteViewController: KYCViewController, KYCCompleteDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCCompleteBusinessLogic?
    var router: (NSObjectProtocol & KYCCompleteRoutingLogic)?
    
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
        let interactor = KYCCompleteInteractor()
        let presenter = KYCCompletePresenter()
        let router = KYCCompleteRouter()
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
        case progress
        case textAndImage
        case buttons
    }
    
    private let sections: [Section] = [
        .progress,
        .textAndImage,
        .buttons
    ]
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<KYCProgressView>.self)
        tableView.register(CellWrapperView<KYCTextAndImageView>.self)
        tableView.register(CellWrapperView<KYCCompleteButtonsView>.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .progress:
            return getKYCProgressCell(indexPath)
            
        case .textAndImage:
            return getKYCTextAndImageCell(indexPath)
            
        case .buttons:
            return getKYCCompleteButtons(indexPath)
            
        }
    }
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCProgressView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.setup(with: .init(text: "KYC COMPLETE!",
                                   stepCount: KYCProgressView.PersonalInformationProgress.allCases.count,
                                   currentStep: KYCProgressView.PersonalInformationProgress.complete.rawValue))
        }
        
        return cell
    }
    
    func getKYCTextAndImageCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCTextAndImageView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.setup(with: .init(text: "Your profile is under review.\nYou will recieve an email with the status of your review in 1-2 business days.", image: UIImage(named: "KYC Complete")))
        }
        
        return cell
    }
    
    func getKYCCompleteButtons(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCCompleteButtonsView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didTapDoneButton = { [weak self] in
                self?.router?.dismissFlow()
            }
        }
        
        return cell
    }
}
