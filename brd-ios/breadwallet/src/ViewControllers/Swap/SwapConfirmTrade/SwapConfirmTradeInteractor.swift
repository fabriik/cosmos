//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapConfirmTradeBusinessLogic {
    // MARK: Business logic functions
}

protocol SwapConfirmTradeDataStore {
    // MARK: Data store
}

class SwapConfirmTradeInteractor: SwapConfirmTradeBusinessLogic, SwapConfirmTradeDataStore {
    var presenter: SwapConfirmTradePresentationLogic?

    // MARK: Interactor functions

}
