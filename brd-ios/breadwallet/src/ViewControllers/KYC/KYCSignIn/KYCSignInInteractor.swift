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
    
    var fieldValidationIsAllowed: [KYCSignIn.FieldType: Bool] { get set }
}

class KYCSignInInteractor: KYCSignInBusinessLogic, KYCSignInDataStore {
    var presenter: KYCSignInPresentationLogic?
    
    // MARK: Interactor functions
    
    var email: String?
    var password: String?
    
    var fieldValidationIsAllowed = [KYCSignIn.FieldType: Bool]()
    
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
        validationValues.append(Validator.validatePassword(value: password ?? "", completion: { [weak self] isViable in
            guard let password = self?.password else { return }
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, type: .password, isFieldEmpty: password.isEmpty))
        }))
        validationValues.append(Validator.validateEmail(value: email ?? "", completion: { [weak self] isViable in
            guard let email = self?.email else { return }
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, type: .email, isFieldEmpty: email.isEmpty))
        }))
        validationValues.append(contentsOf: fieldValidationIsAllowed.values)
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableSubmit(response: .init(shouldEnable: shouldEnable))
    }
}
