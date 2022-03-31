//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyRoutingLogic {
    var dataStore: SwapPickCurrencyDataStore? { get }
    
    func showSwapHistory()
}

class SwapPickCurrencyRouter: NSObject, SwapPickCurrencyRoutingLogic {
    weak var viewController: SwapPickCurrencyViewController?
    var dataStore: SwapPickCurrencyDataStore?
    
    func showSwapHistory() {
        // TODO: do this to do.
    }
}
