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
        presenter?.presentData(actionResponse: .init(item: dataStore?.email))
    }
    
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction) {
        dataStore?.code = viewAction.item
        presenter?.presentValidate(actionResponse: .init(item: viewAction.item))
    }
    
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction) {
        let data = RegistrationConfirmationRequestData(code: dataStore?.code)
        RegistrationConfirmationWorker().execute(requestData: data) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            
            // TODO: confirmed
            UserManager.shared.refresh()
            UserDefaults.emailConfirmed = true
            
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
