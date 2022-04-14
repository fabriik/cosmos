// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCForgotPasswordPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentSubmitData(response: KYCForgotPassword.SubmitData.Response)
    func presentShouldEnableConfirm(response: KYCForgotPassword.ShouldEnableConfirm.Response)
    func presentValidateField(response: KYCForgotPassword.ValidateField.Response)
    func presentError(response: GenericModels.Error.Response)
}

class KYCForgotPasswordPresenter: KYCForgotPasswordPresentationLogic {
    weak var viewController: KYCForgotPasswordDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentSubmitData(response: KYCForgotPassword.SubmitData.Response) {
        viewController?.displaySubmitData(viewModel: .init())
    }
    
    func presentShouldEnableConfirm(response: KYCForgotPassword.ShouldEnableConfirm.Response) {
        viewController?.displayShouldEnableConfirm(viewModel: .init(shouldEnable: response.shouldEnable))
    }
    
    func presentValidateField(response: KYCForgotPassword.ValidateField.Response) {
        viewController?.displayValidateField(viewModel: .init(isViable: response.isViable,
                                                              isFieldEmpty: response.isFieldEmpty,
                                                              type: response.type))
    }
    
    func presentError(response: GenericModels.Error.Response) {
        viewController?.displayError(viewModel: .init(error: response.error?.errorMessage ?? ""))
    }
}
