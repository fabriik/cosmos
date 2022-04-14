// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCResetPasswordBusinessLogic {
    // MARK: Business logic functions
    
    func executeCheckFieldType(request: KYCResetPassword.CheckFieldText.Request)
    func executeSubmitData(request: KYCResetPassword.SubmitData.Request)
}

protocol KYCResetPasswordDataStore {
    // MARK: Data store
    
    var recoveryCode: String? { get set }
    var password: String? { get set }
    var passwordRepeat: String? { get set }
}

class KYCResetPasswordInteractor: KYCResetPasswordBusinessLogic, KYCResetPasswordDataStore {
    var presenter: KYCResetPasswordPresentationLogic?
    
    // MARK: Interactor functions
    
    var recoveryCode: String?
    var password: String?
    var passwordRepeat: String?
    
    func executeSubmitData(request: KYCResetPassword.SubmitData.Request) {
        let worker = KYCResetPasswordWorker()
        let workerUrlModelData = KYCResetPasswordWorkerUrlModelData()
        let workerRequest = KYCResetPasswordWorkerRequest(key: recoveryCode, password: password)
        let workerData = KYCResetPasswordWorkerData(workerRequest: workerRequest,
                                                    workerUrlModelData: workerUrlModelData)

        worker.execute(requestData: workerData) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }

            self?.presenter?.presentSubmitData(response: .init())
        }
    }
    
    func executeCheckFieldType(request: KYCResetPassword.CheckFieldText.Request) {
        switch request.type {
        case .recoveryCode:
            recoveryCode = request.text
            
        case .password:
            password = request.text
            
        case .passwordRepeat:
            passwordRepeat = request.text
            
        }
        
        checkCredentials()
    }
    
    private func checkCredentials() {
        var validationValues = [Bool]()
        validationValues.append(!recoveryCode.isNilOrEmpty)
        validationValues.append(!password.isNilOrEmpty)
        validationValues.append(!passwordRepeat.isNilOrEmpty)
        validationValues.append(Validator.validatePassword(value: password ?? "", completion: { [weak self] isViable in
            let isFieldEmpty = (self?.password ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, isFieldEmpty: isFieldEmpty, type: .password))
        }))
        validationValues.append(Validator.validatePassword(value: passwordRepeat ?? "", completion: { [weak self] isViable in
            let isFieldEmpty = (self?.passwordRepeat ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable && self?.password == self?.passwordRepeat,
                                                                  isFieldEmpty: isFieldEmpty,
                                                                  type: .passwordRepeat))
        }))
        validationValues.append(Validator.validateConfirmationCode(value: recoveryCode ?? "", completion: { [weak self] isViable in
            let isFieldEmpty = (self?.recoveryCode ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, isFieldEmpty: isFieldEmpty, type: .recoveryCode))
        }))
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableConfirm(response: .init(shouldEnable: shouldEnable))
    }
}
