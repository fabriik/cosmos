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
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction)
}

protocol ProfileActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse)
}

protocol ProfileResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay)
}

protocol ProfileDataStore: BaseDataStore, FetchDataStore {
}

protocol ProfileDataPassing {
    var dataStore: ProfileDataStore? { get }
}

protocol ProfileRoutes: CoordinatableRoutes {
    func showAvatarSelection()
}
