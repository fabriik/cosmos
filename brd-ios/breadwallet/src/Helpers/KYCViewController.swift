// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCViewController: UIViewController {
    // MARK: - Variables
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setupDefault()
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    lazy var roundedView: RoundedView = {
        let roundedView = RoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.cornerRadius = 10
        roundedView.backgroundColor = Theme.primaryBackground
        
        return roundedView
    }()
    
    lazy var footerView: KYCFooterView = {
        let footerView = KYCFooterView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        return footerView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presetUI()
        setupUI()
        fetch()
        localize()
    }
    
    private func presetUI() {
        view.addSubview(roundedView)
        roundedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        roundedView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        roundedView.addSubview(footerView)
        footerView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -40).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        roundedView.addSubview(tableView)
        tableView.contentInset.bottom = 100
        tableView.topAnchor.constraint(equalTo: roundedView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor).isActive = true
        
        view.backgroundColor = .almostBlack
    }
    
    // MARK: - Overrides
    
    // Override to add localizations
    func localize() {}
    
    // Override to do any UI updates
    func setupUI() {}
    
    // Override to pre-fetch data
    func fetch() {}
}
