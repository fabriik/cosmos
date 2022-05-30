//
//  PersonalInfoVIP.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

extension Scenes {
    static let PersonalInfo = PersonalInfoViewController.self
}

protocol PersonalInfoViewActions: BaseViewActions, FetchViewActions {
}

protocol PersonalInfoActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol PersonalInfoResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol PersonalInfoDataStore: BaseDataStore, FetchDataStore {
}

protocol PersonalInfoDataPassing {
    var dataStore: PersonalInfoDataStore? { get }
}

protocol PersonalInfoRoutes: CoordinatableRoutes {
}
