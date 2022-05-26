//
//  ProfileVIP.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

extension Scenes {
    static let Profile = ProfileViewController.self
}

protocol ProfileViewActions: BaseViewActions, FetchViewActions {
}

protocol ProfileActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol ProfileResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol ProfileDataStore: BaseDataStore, FetchDataStore {
}

protocol ProfileDataPassing {
    var dataStore: ProfileDataStore? { get }
}

protocol ProfileRoutes: CoordinatableRoutes {
}
