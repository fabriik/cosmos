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
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    // MARK: - Aditional helpers
}
