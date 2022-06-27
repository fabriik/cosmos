//
//  ResetPinVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 27.6.22.
//
//

import UIKit
import CLEANerSwift

extension Scenes {
    static let ResetPin = ResetPinViewController.self
}

protocol ResetPinViewActions: BaseViewActions {
}

protocol ResetPinActionResponses: BaseActionResponses {
}

protocol ResetPinResponseDisplays: AnyObject, BaseResponseDisplays {
}

protocol ResetPinDataStore: BaseDataStore {
}

protocol ResetPinDataPassing {
    var dataStore: ResetPinDataStore? { get }
}

protocol ResetPinRoutes: CoordinatableRoutes {
}
