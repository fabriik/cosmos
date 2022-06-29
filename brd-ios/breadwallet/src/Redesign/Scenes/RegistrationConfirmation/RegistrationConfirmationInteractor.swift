//
//  RegistrationConfirmationInteractor.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationInteractor: NSObject, Interactor, RegistrationConfirmationViewActions {
    typealias Models = RegistrationConfirmationModels

    var presenter: RegistrationConfirmationPresenter?
    var dataStore: RegistrationConfirmationStore?

    // MARK: - RegistrationConfirmationViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard UserDefaults.emailConfirmed != true else {
            presenter?.presentData(actionResponse: .init(item: UserDefaults.email))
            return
        }
        
        // if session has expired, we need to call new device again
        guard let email = UserDefaults.email, let token = UserDefaults.walletTokenValue else { return }
        
        let newDeviceRequestData = NewDeviceRequestData(token: token)
        NewDeviceWorker().execute(requestData: newDeviceRequestData) { [weak self] result in
            switch result {
            case .success(let data):
                UserDefaults.email = data.email
                UserDefaults.kycSessionKeyValue = data.sessionKey
                
                self?.presenter?.presentData(actionResponse: .init(item: email))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction) {
        let code = viewAction.item ?? ""
        dataStore?.code = code
        guard code.count <= 6 else { return }
        
        presenter?.presentValidate(actionResponse: .init(isValid: code.count == 6))
    }
    
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction) {
        let data = RegistrationConfirmationRequestData(code: dataStore?.code)
        RegistrationConfirmationWorker().execute(requestData: data) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(actionResponse: .init())
                return
            }
            
            // TODO: confirmed
            UserDefaults.emailConfirmed = true
            UserManager.shared.refresh()
            
            self?.presenter?.presentConfirm(actionResponse: .init())
        }
    }
    
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction) {
        ResendConfirmationWorker().execute { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            self?.presenter?.presentResend(actionResponse: .init())
        }
    }

    // MARK: - Aditional helpers
}
