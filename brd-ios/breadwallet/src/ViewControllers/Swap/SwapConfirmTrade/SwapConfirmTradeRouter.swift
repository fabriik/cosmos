//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapConfirmTradeRoutingLogic {
    var dataStore: SwapConfirmTradeDataStore? { get }
}

class SwapConfirmTradeRouter: NSObject, SwapConfirmTradeRoutingLogic {
    weak var viewController: SwapConfirmTradeViewController?
    var dataStore: SwapConfirmTradeDataStore?
}
