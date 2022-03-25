//
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum SwapPickCurrency {
    // MARK: Model name declarations
    
    enum GetCurrencyList {
        struct Currency {
            let image: UIImage?
            let title: String
            let subtitle: String
            let amount: String
            let conversion: String
            var isVisible: Bool
        }
        
        struct Request {}
        struct Response {
            let currencies: [Currency]
        }
        struct ViewModel {
            let currencies: [Currency]
        }
    }
}
