//
//  ItemSelectionCoordinator.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionCoordinator: BaseCoordinator, ItemSelectionRoutes {
    // MARK: - ItemSelectionRoutes
    override func start() {
        open(scene: Scenes.ItemSelection)
    }
    
    override func goBack() {
        parentCoordinator?.childDidFinish(child: self)
        navigationController.dismiss(animated: true)
    }

    // MARK: - Aditional helpers
}
