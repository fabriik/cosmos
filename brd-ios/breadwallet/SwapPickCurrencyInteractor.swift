//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapPickCurrencyBusinessLogic {
    // MARK: Business logic functions
    
    func executeGetCurrencyList(request: SwapPickCurrency.GetCurrencyList.Request)
}

protocol SwapPickCurrencyDataStore {
    // MARK: Data store
}

class SwapPickCurrencyInteractor: SwapPickCurrencyBusinessLogic, SwapPickCurrencyDataStore {
    var presenter: SwapPickCurrencyPresentationLogic?
    
    // MARK: Interactor functions
    
    func executeGetCurrencyList(request: SwapPickCurrency.GetCurrencyList.Request) {
        var currencies: [SwapPickCurrency.GetCurrencyList.Currency] = []
        
        for _ in 0...20 {
            currencies.append(SwapPickCurrency.GetCurrencyList.Currency(image: UIImage(named: "TouchId-Large"),
                                                                        title: NSUUID().uuidString,
                                                                        subtitle: "BCH",
                                                                        amount: "$19,34636.44",
                                                                        conversion: "1,5678.00 BCH",
                                                                        isVisible: true))
        }
        
        presenter?.presentGetCurrencyList(response: .init(currencies: currencies))
    }
}
