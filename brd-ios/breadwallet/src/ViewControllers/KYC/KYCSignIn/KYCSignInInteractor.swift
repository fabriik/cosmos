//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCSignInBusinessLogic {
    // MARK: Business logic functions
    
    func executeCheckFieldType(request: KYCSignIn.CheckFieldText.Request)
    func executeSignIn(request: KYCSignIn.SubmitData.Request)
}

protocol KYCSignInDataStore {
    // MARK: Data store
    
    var email: String? { get set }
    var password: String? { get set }
}

class KYCSignInInteractor: KYCSignInBusinessLogic, KYCSignInDataStore {
    var presenter: KYCSignInPresentationLogic?
    
    // MARK: Interactor functions
    
    var email: String?
    var password: String?
    
    func executeSignIn(request: KYCSignIn.SubmitData.Request) {
        let worker = KYCSignInWorker()
        let workerUrlModelData = KYCSignInWorkerUrlModelData()
        let workerRequest = KYCSignInWorkerRequest(email: email,
                                                   password: password)
        let workerData = KYCSignInWorkerData(workerRequest: workerRequest,
                                             workerUrlModelData: workerUrlModelData)
        
        worker.execute(requestData: workerData) { [weak self] response, error in
            guard let sessionKey = response?.data["sessionKey"]?.value as? String,
                  let isConfirmed = response?.data["is_confirmed"]?.value as? Bool,
                    error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }
            
            UserDefaults.kycSessionKeyValue = sessionKey
            
            if isConfirmed == false {
                self?.presenter?.presentConfirmEmail(response: .init())
            } else {
                self?.presenter?.presentSignIn(response: .init())
            }
        }
    }
    
    func executeCheckFieldType(request: KYCSignIn.CheckFieldText.Request) {
        switch request.type {
        case .email:
            email = request.text
            
        case .password:
            password = request.text
            
        }
        
        checkCredentials()
    }
    
    private func checkCredentials() {
        var validationValues = [Bool]()
        validationValues.append(!email.isNilOrEmpty)
        validationValues.append(!password.isNilOrEmpty)
        
        let isPasswordFieldEmpty = (password ?? "").isEmpty
        presenter?.presentValidateField(response: .init(isFieldEmpty: isPasswordFieldEmpty, type: .password))

        let isEmailFieldEmpty = (email ?? "").isEmpty
        presenter?.presentValidateField(response: .init(isFieldEmpty: isEmailFieldEmpty, type: .email))
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableSubmit(response: .init(shouldEnable: shouldEnable))
    }
}
