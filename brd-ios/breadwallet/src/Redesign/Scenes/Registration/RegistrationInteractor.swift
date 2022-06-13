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
    
    func next(viewACtion: RegistrationModels.Next.ViewAction) {
        guard let email = dataStore?.email, let token = UserDefaults.sessionKeyValue else { return }
        
        let data = RegistrationRequestData(email: email, token: token)
        RegistrationWorker().execute(requestData: data) { [weak self] data, error in
            guard let sessionKey = data?.sessionKey,
                  error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            
            UserDefaults.email = email
            UserDefaults.kycSessionKeyValue = sessionKey
            
            self?.presenter?.presentNext(actionResponse: .init(email: email))
        }
    }
    
    // MARK: - Aditional helpers
}
