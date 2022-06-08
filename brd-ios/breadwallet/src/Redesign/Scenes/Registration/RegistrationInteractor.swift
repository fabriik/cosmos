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
        presenter?.presentNotification(actionResponse: .init(text: "\(RegistrationWorker().getUrl())"))
    }
    
    func validate(viewAction: RegistrationModels.Validate.ViewAction) {
        dataStore?.email = viewAction.item
        
        presenter?.presentValidate(actionResponse: .init(item: dataStore?.email))
    }
    
    func next(viewACtion: RegistrationModels.Next.ViewAction) {
        guard let email = dataStore?.email else {
            presenter?.presentNotification(actionResponse: .init(text: "no keystore token"))
            return
        }
        
        guard let tokenData = try? KeyStore.create().apiUserAccount else {
            presenter?.presentNotification(actionResponse: .init(text: "no api user account"))
            return
        }
        
        guard let token = tokenData["token"] as? String else {
            presenter?.presentNotification(actionResponse: .init(text: "no token"))
            return
        }
        
        let data = RegistrationRequestData(email: email, token: token)
        RegistrationWorker().execute(requestData: data) { [weak self] data, error in
            guard let sessionKey = data?.sessionKey,
                  error == nil else {
                // TODO: handle error
                self?.presenter?.presentNotification(actionResponse: .init(text: "\(error)"))
                return
            }
            self?.presenter?.presentNotification(actionResponse: .init(text: "got new session key \(sessionKey)"))
            UserDefaults.email = email
            UserDefaults.kycSessionKeyValue = sessionKey
            self?.presenter?.presentNext(actionResponse: .init(email: email))
        }
    }
    
    // MARK: - Aditional helpers
}
