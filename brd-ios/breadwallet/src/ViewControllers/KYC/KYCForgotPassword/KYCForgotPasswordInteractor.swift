// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCForgotPasswordBusinessLogic {
    // MARK: Business logic functions
    
    func executeCheckFieldType(request: KYCForgotPassword.CheckFieldText.Request)
    func executeSubmitData(request: KYCForgotPassword.SubmitData.Request)
}

protocol KYCForgotPasswordDataStore {
    // MARK: Data store
    
    var email: String? { get set }
}

class KYCForgotPasswordInteractor: KYCForgotPasswordBusinessLogic, KYCForgotPasswordDataStore {
    var presenter: KYCForgotPasswordPresentationLogic?
    
    // MARK: Interactor functions

    var email: String?
    
    func executeSubmitData(request: KYCForgotPassword.SubmitData.Request) {
        let worker = KYCForgotPasswordWorker()
        let workerUrlModelData = KYCForgotPasswordWorkerUrlModelData()
        let workerRequest = KYCForgotPasswordWorkerRequest(email: email ?? "")
        let workerData = KYCForgotPasswordWorkerData(workerRequest: workerRequest,
                                                     workerUrlModelData: workerUrlModelData)
        
        worker.execute(requestData: workerData) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }
            
            self?.presenter?.presentSubmitData(response: .init())
        }
    }
    
    func executeCheckFieldType(request: KYCForgotPassword.CheckFieldText.Request) {
        email = request.text
        
        checkCredentials()
    }
    
    private func checkCredentials() {
        var validationValues = [Bool]()
        validationValues.append(!email.isNilOrEmpty)
        validationValues.append(validateEmailUsingRegex())
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableConfirm(response: .init(shouldEnable: shouldEnable))
    }
    
    private func validateEmailUsingRegex() -> Bool {
        let emailFormat = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        
        let isViable = emailPredicate.evaluate(with: email)
        
        presenter?.presentValidateField(response: .init(isViable: isViable, type: .email))
        
        return isViable
    }
}
