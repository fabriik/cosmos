//
//  AssetSelectionCoordinator.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 6.7.22.
//
//

import UIKit

class AssetSelectionCoordinator: BaseCoordinator, AssetSelectionRoutes {
    // MARK: - AssetSelectionRoutes
    override func start() {
        open(scene: Scenes.AssetSelection)
    }
    
    override func goBack() {
        parentCoordinator?.childDidFinish(child: self)
        navigationController.dismiss(animated: true)
    }

    // MARK: - Aditional helpers
}
