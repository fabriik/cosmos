//
//  SwapDetailsVIP.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

extension Scenes {
    static let SwapDetails = SwapDetailsViewController.self
}

protocol SwapDetailsViewActions: BaseViewActions {
}

protocol SwapDetailsActionResponses: BaseActionResponses {
}

protocol SwapDetailsResponseDisplays: AnyObject, BaseResponseDisplays {
}

protocol SwapDetailsDataStore: BaseDataStore {
}

protocol SwapDetailsDataPassing {
    var dataStore: SwapDetailsDataStore? { get }
}

protocol SwapDetailsRoutes: CoordinatableRoutes {
}
