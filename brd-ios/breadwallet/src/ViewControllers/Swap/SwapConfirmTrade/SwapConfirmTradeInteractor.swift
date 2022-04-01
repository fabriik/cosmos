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
    var worker: SwapConfirmTradeWorker?

    // MARK: Interactor functions

}
