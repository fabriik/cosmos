//
//  SwapMainModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SwapMainModels {
    typealias Item = ()
    
    enum Sections: Sectionable {
        case swapCard
        case confirm
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Amounts {
        struct CurrencyData {
            var formattedString: String?
            var number: NSNumber?
        }
        
        struct ViewAction {
            var fromFiatAmount: CurrencyData?
            var fromCryptoAmount: CurrencyData?
            var toFiatAmount: CurrencyData?
            var toCryptoAmount: CurrencyData?
        }
        
        struct ActionResponse {
            var fromFiatAmount: CurrencyData?
            var fromCryptoAmount: CurrencyData?
            var toFiatAmount: CurrencyData?
            var toCryptoAmount: CurrencyData?
        }
        
        struct ResponseDisplay {
            var fromFiatAmount: CurrencyData?
            var fromCryptoAmount: CurrencyData?
            var toFiatAmount: CurrencyData?
            var toCryptoAmount: CurrencyData?
            var shouldEnableConfirm: Bool
        }
    }
}
