//
//  SwapModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SwapModels {
    typealias Item = ()
    
    enum Sections: Sectionable {
        case swapCard
        case confirm
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Amounts {
        struct ViewAction {
            var fromFiatAmount: String? = nil
            var fromCryptoAmount: String? = nil
            var toFiatAmount: String? = nil
            var toCryptoAmount: String? = nil
        }
        
        struct ActionResponse {
            var fromFiatAmount: NSNumber?
            var fromCryptoAmount: NSNumber?
            var toFiatAmount: NSNumber?
            var toCryptoAmount: NSNumber?
        }
        
        struct ResponseDisplay {
            var amounts: MainSwapViewModel
            var shouldEnableConfirm: Bool
        }
    }
}
