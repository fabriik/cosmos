//
//  SwapMainStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapMainStore: NSObject, BaseDataStore, SwapMainDataStore {
    // MARK: - SwapMainDataStore
    
    var itemId: String?
    var fromFiatAmount: SwapMainModels.Amounts.CurrencyData?
    var fromCryptoAmount: SwapMainModels.Amounts.CurrencyData?
    var toFiatAmount: SwapMainModels.Amounts.CurrencyData?
    var toCryptoAmount: SwapMainModels.Amounts.CurrencyData?
    
    // MARK: - Aditional helpers
}
