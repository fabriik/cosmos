//
//  KYCResetPasswordSuccessViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/04/2022.
//  Copyright (c) 2022 Fabriik Exchange, LLC. All rights reserved.
//

import UIKit

protocol KYCResetPasswordSuccessDisplayLogic: AnyObject {
    // MARK: Display logic functions
}

class KYCResetPasswordSuccessViewController: KYCViewController, KYCResetPasswordSuccessDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCResetPasswordSuccessBusinessLogic?
    var router: (NSObjectProtocol & KYCResetPasswordSuccessRoutingLogic)?
    
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
        let interactor = KYCResetPasswordSuccessInteractor()
        let presenter = KYCResetPasswordSuccessPresenter()
        let router = KYCResetPasswordSuccessRouter()
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
        case content
    }
    
    private let sections: [Section] = [
        .content
    ]
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<KYCResetSuccessView>.self)
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
        case .content:
            return getKYCResetSuccessCell(indexPath)
            
        }
    }
    
    func getKYCResetSuccessCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCResetSuccessView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didTapLoginButton = { [weak self] in
                self?.router?.dismissFlow()
            }
        }
        
        return cell
    }
}
