//
//  SwapMainVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SwapMain = SwapMainViewController.self
}

protocol SwapMainViewActions: BaseViewActions, FetchViewActions {
    func setAmount(viewAction: SwapMainModels.Amounts.ViewAction)
}

protocol SwapMainActionResponses: BaseActionResponses, FetchActionResponses {
    func presentSetAmount(actionResponse: SwapMainModels.Amounts.ActionResponse)
}

protocol SwapMainResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displaySetAmount(responseDisplay: SwapMainModels.Amounts.ResponseDisplay)
}

protocol SwapMainDataStore: BaseDataStore, FetchDataStore {
    var fromFiatAmount: SwapMainModels.Amounts.CurrencyData? { get set }
    var fromCryptoAmount: SwapMainModels.Amounts.CurrencyData? { get set }
    var toFiatAmount: SwapMainModels.Amounts.CurrencyData? { get set }
    var toCryptoAmount: SwapMainModels.Amounts.CurrencyData? { get set }
}

protocol SwapMainDataPassing {
    var dataStore: SwapMainDataStore? { get }
}

protocol SwapMainRoutes: CoordinatableRoutes {
}
