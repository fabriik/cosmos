//
//  ProfileInteractor.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

class ProfileInteractor: NSObject, Interactor, ProfileViewActions {
    
    typealias Models = ProfileModels

    var presenter: ProfilePresenter?
    var dataStore: ProfileStore?

    // MARK: - ProfileViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        // TODO: fetch/pass user info
        presenter?.presentData(actionResponse: .init(item: Models.Item(title: "Under construction", image: "earth")))
    }
    
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction) {
        presenter?.presentVerificationInfo(actionResponse: .init())
    }
    
    func navigate(viewAction: ProfileModels.Navigate.ViewAction) {
        presenter?.presentNavigation(actionResponse: .init(index: viewAction.index))
    }
    
    // MARK: - Aditional helpers
}
