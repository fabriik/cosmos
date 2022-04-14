// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCResetPasswordPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentSubmitData(response: KYCResetPassword.SubmitData.Response)
    func presentShouldEnableConfirm(response: KYCResetPassword.ShouldEnableConfirm.Response)
    func presentValidateField(response: KYCResetPassword.ValidateField.Response)
    func presentError(response: GenericModels.Error.Response)
}

class KYCResetPasswordPresenter: KYCResetPasswordPresentationLogic {
    weak var viewController: KYCResetPasswordDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentSubmitData(response: KYCResetPassword.SubmitData.Response) {
        viewController?.displaySubmitData(viewModel: .init())
    }
    
    func presentShouldEnableConfirm(response: KYCResetPassword.ShouldEnableConfirm.Response) {
        viewController?.displayShouldEnableConfirm(viewModel: .init(shouldEnable: response.shouldEnable))
    }
    
    func presentValidateField(response: KYCResetPassword.ValidateField.Response) {
        viewController?.displayValidateField(viewModel: .init(isViable: response.isViable,
                                                              type: response.type,
                                                              isFieldEmpty: response.isFieldEmpty))
    }
    
    func presentError(response: GenericModels.Error.Response) {
        viewController?.displayError(viewModel: .init(error: response.error?.errorMessage ?? ""))
    }
}
