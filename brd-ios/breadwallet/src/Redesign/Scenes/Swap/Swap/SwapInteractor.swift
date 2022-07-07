//
//  SwapInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapInteractor: NSObject, Interactor, SwapViewActions {
    
    typealias Models = SwapModels

    var presenter: SwapPresenter?
    var dataStore: SwapStore?

    // MARK: - SwapViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item()))
    }
    
    func setAmount(viewAction: SwapModels.Amounts.ViewAction) {
        dataStore?.fromFiatAmount = NSNumber(value: (((viewAction.fromFiatAmount as? NSString)?.doubleValue ?? 0) / 100))
        dataStore?.fromCryptoAmount = NSNumber(value: (((viewAction.fromCryptoAmount as? NSString)?.doubleValue ?? 0) / 100))
        dataStore?.toFiatAmount = NSNumber(value: (((viewAction.toFiatAmount as? NSString)?.doubleValue ?? 0) / 100))
        dataStore?.toCryptoAmount = NSNumber(value: (((viewAction.toCryptoAmount as? NSString)?.doubleValue ?? 0) / 100))
        
        presenter?.presentSetAmount(actionResponse: .init(fromFiatAmount: dataStore?.fromFiatAmount,
                                                          fromCryptoAmount: dataStore?.fromCryptoAmount,
                                                          toFiatAmount: dataStore?.toFiatAmount,
                                                          toCryptoAmount: dataStore?.toCryptoAmount))
    }
    
    // MARK: - Aditional helpers
}
