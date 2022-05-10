//
//  DemoVIP.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit

extension Scenes {
    static let Demo = DemoViewController.self
}

protocol DemoViewActions: BaseViewActions {
}

protocol DemoActionResponses: BaseActionResponses {
}

protocol DemoResponseDisplays: AnyObject, BaseResponseDisplays {
}

protocol DemoDataStore: BaseDataStore {
}

protocol DemoDataPassing {
    var dataStore: DemoDataStore? { get }
}

protocol DemoRoutes: CoordinatableRoutes {
}
