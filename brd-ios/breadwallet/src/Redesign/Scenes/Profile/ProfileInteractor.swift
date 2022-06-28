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
        presenter?.presentError(actionResponse: .init(error: SessioExpiredError()))
        return ()
        
        ProfileWorker().execute { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.profile = data
                self?.presenter?.presentData(actionResponse: .init(item: Models.Item(title: data.email, image: "earth", status: data.status)))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
            }
        }
    }
    
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction) {
        presenter?.presentVerificationInfo(actionResponse: .init())
    }
    
    func navigate(viewAction: ProfileModels.Navigate.ViewAction) {
        presenter?.presentNavigation(actionResponse: .init(index: viewAction.index))
    }
    
    // MARK: - Aditional helpers
}
