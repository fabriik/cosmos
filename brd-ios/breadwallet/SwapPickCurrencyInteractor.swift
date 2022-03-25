//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyBusinessLogic {
    // MARK: Business logic functions
}

protocol SwapPickCurrencyDataStore {
    // MARK: Data store
}

class SwapPickCurrencyInteractor: SwapPickCurrencyBusinessLogic, SwapPickCurrencyDataStore {
    var presenter: SwapPickCurrencyPresentationLogic?
    
    // MARK: Interactor functions

}
