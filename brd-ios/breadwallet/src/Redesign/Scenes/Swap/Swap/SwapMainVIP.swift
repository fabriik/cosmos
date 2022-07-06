//
//  SwapVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let Swap = SwapViewController.self
}

protocol SwapViewActions: BaseViewActions, FetchViewActions {
    func setAmount(viewAction: SwapModels.Amounts.ViewAction)
}

protocol SwapActionResponses: BaseActionResponses, FetchActionResponses {
    func presentSetAmount(actionResponse: SwapModels.Amounts.ActionResponse)
}

protocol SwapResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displaySetAmount(responseDisplay: SwapModels.Amounts.ResponseDisplay)
}

protocol SwapDataStore: BaseDataStore, FetchDataStore {
    var fromFiatAmount: NSNumber? { get set }
    var fromCryptoAmount: NSNumber? { get set }
    var toFiatAmount: NSNumber? { get set }
    var toCryptoAmount: NSNumber? { get set }
}

protocol SwapDataPassing {
    var dataStore: SwapDataStore? { get }
}

protocol SwapRoutes: CoordinatableRoutes {
}
