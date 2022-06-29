//
//  RegistrationInteractor.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationInteractor: NSObject, Interactor, RegistrationViewActions {
    typealias Models = RegistrationModels

    var presenter: RegistrationPresenter?
    var dataStore: RegistrationStore?

    // MARK: - RegistrationViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let item = Models.Item(dataStore?.email, dataStore?.type)
        presenter?.presentData(actionResponse: .init(item: item))
    }
    
    func validate(viewAction: RegistrationModels.Validate.ViewAction) {
        dataStore?.email = viewAction.item
        
        presenter?.presentValidate(actionResponse: .init(item: dataStore?.email))
    }
    
    func next(viewAction: RegistrationModels.Next.ViewAction) {
        guard let email = dataStore?.email, let token = UserDefaults.walletTokenValue else { return }
        
        let data = RegistrationRequestData(email: email, token: token)
        RegistrationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data.sessionKey else { return }
                
                UserDefaults.email = email
                UserDefaults.kycSessionKeyValue = sessionKey
                
                self?.presenter?.presentNext(actionResponse: .init(email: email))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
            }
        }
    }
    
    // MARK: - Aditional helpers
}
