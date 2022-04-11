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
        validationValues.append(Validator.validateEmail(value: email ?? "", completion: { [weak self] isViable in
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, type: .email))
        }))
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableConfirm(response: .init(shouldEnable: shouldEnable))
    }
}
