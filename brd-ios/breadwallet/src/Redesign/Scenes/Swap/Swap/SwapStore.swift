//
//  SwapStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapStore: NSObject, BaseDataStore, SwapDataStore {
    // MARK: - SwapDataStore
    
    var itemId: String?
    var fromFiatAmount: NSNumber?
    var fromCryptoAmount: NSNumber?
    var toFiatAmount: NSNumber?
    var toCryptoAmount: NSNumber?
    
    // MARK: - Aditional helpers
}
