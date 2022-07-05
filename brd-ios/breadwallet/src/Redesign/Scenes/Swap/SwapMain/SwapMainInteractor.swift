//
//  SwapMainInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapMainInteractor: NSObject, Interactor, SwapMainViewActions {
    
    typealias Models = SwapMainModels

    var presenter: SwapMainPresenter?
    var dataStore: SwapMainStore?

    // MARK: - SwapMainViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item()))
    }
    
    func setAmount(viewAction: SwapMainModels.Amounts.ViewAction) {
        dataStore?.toCryptoAmount = viewAction.fromFiatAmount
        dataStore?.fromCryptoAmount = viewAction.fromCryptoAmount
        dataStore?.toFiatAmount = viewAction.toFiatAmount
        dataStore?.toCryptoAmount = viewAction.toCryptoAmount
        
        presenter?.presentSetAmount(actionResponse: .init(fromFiatAmount: dataStore?.fromFiatAmount,
                                                          fromCryptoAmount: dataStore?.fromCryptoAmount,
                                                          toFiatAmount: dataStore?.toFiatAmount,
                                                          toCryptoAmount: dataStore?.toCryptoAmount))
    }
    
    // MARK: - Aditional helpers
}
