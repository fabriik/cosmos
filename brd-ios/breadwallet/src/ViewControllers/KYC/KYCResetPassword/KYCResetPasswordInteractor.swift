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
        validationValues.append(validatePasswordUsingRegex())
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableConfirm(response: .init(shouldEnable: shouldEnable))
    }
    
    private func validatePasswordUsingRegex() -> Bool {
        guard let password = password, let passwordRepeat = passwordRepeat else { return false }
        
        let numberFormat = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberFormat)
        
        let isViable = numberPredicate.evaluate(with: password)
        
        presenter?.presentValidateField(response: .init(isViable: isViable && password == passwordRepeat, type: .password))
        presenter?.presentValidateField(response: .init(isViable: isViable && password == passwordRepeat, type: .passwordRepeat))

        return isViable
    }
}
