//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentGetCurrencyList(response: SwapPickCurrency.GetCurrencyList.Response)
}

class SwapPickCurrencyPresenter: SwapPickCurrencyPresentationLogic {
    weak var viewController: SwapPickCurrencyDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentGetCurrencyList(response: SwapPickCurrency.GetCurrencyList.Response) {
        viewController?.displayGetCurrencyList(viewModel: .init(currencies: response.currencies))
    }
}
