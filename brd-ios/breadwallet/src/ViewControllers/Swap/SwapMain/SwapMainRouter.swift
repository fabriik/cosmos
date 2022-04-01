//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainRoutingLogic {
    var dataStore: SwapMainDataStore? { get }
    
    func showSwapConfirmTrade()
}

class SwapMainRouter: NSObject, SwapMainRoutingLogic {
    weak var viewController: SwapMainViewController?
    var dataStore: SwapMainDataStore?
    
    func showSwapConfirmTrade() {
        let vc = SwapConfirmTradeViewController()
        let navController = SwapNavigationController(rootViewController: vc)
        viewController?.present(navController, animated: true, completion: nil)
    }
}
