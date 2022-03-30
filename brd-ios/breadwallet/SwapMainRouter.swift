//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainRoutingLogic {
    var dataStore: SwapMainDataStore? { get }
}

class SwapMainRouter: NSObject, SwapMainRoutingLogic {
    weak var viewController: SwapMainViewController?
    var dataStore: SwapMainDataStore?
}
