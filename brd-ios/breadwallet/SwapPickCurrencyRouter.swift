//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyRoutingLogic {
    var dataStore: SwapPickCurrencyDataStore? { get }
}

class SwapPickCurrencyRouter: NSObject, SwapPickCurrencyRoutingLogic {
    weak var viewController: SwapPickCurrencyViewController?
    var dataStore: SwapPickCurrencyDataStore?
}
