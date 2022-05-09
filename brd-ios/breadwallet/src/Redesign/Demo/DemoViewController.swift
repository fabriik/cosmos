//
//  DemoViewController.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit

class DemoViewController: VIPTableViewController<DemoCoordinator,
                          DemoInteractor,
                          DemoPresenter,
                          DemoStore>,
                          DemoResponseDisplays {
    typealias Models = DemoModels

    // MARK: - Overrides

    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.frame = view.frame
        tableView.backgroundColor = Colors.Text.secondary
    }
    
    // MARK: - User Interaction

    // MARK: - DemoResponseDisplay

    // MARK: - Additional Helpers
}
