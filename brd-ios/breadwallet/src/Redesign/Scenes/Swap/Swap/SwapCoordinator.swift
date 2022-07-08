// 
//  SwapCoordinator.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class SwapCoordinator: BaseCoordinator, SwapRoutes {
    // MARK: - ProfileRoutes
    
    override func start() {
        open(scene: Scenes.Swap)
    }
    
    func openAssetSelection() {
        open(scene: Scenes.AssetSelection)
    }
    
    // MARK: - Aditional helpers
    
}
