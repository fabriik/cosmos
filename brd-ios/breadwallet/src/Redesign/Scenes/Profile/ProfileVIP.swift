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
    func navigate(viewAction: ProfileModels.Navigate.ViewAction)
}

protocol ProfileActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse)
    func presentNavigation(actionResponse: ProfileModels.Navigate.ActionResponse)
}

protocol ProfileResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay)
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay)
}

protocol ProfileDataStore: BaseDataStore, FetchDataStore {
    var profile: Profile? { get set }
}

protocol ProfileDataPassing {
    var dataStore: ProfileDataStore? { get }
}

protocol ProfileRoutes: CoordinatableRoutes {
    func showAvatarSelection()
    func showSecuirtySettings()
    func showPreferences()
    func showExport()
}
