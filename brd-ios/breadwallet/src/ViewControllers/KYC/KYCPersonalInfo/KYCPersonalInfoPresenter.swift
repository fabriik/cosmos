// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCPersonalInfoPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentSetDateAndTaxID(response: KYCPersonalInfo.SetDateAndTaxID.Response)
    func presentGetDataForPickerView(response: KYCPersonalInfo.GetDataForPickerView.Response)
    func presentSetPickerValue(response: KYCPersonalInfo.SetPickerValue.Response)
    func presentShouldEnableSubmit(response: KYCPersonalInfo.ShouldEnableSubmit.Response)
    func presentValidateField(response: KYCPersonalInfo.ValidateField.Response)
}

class KYCPersonalInfoPresenter: KYCPersonalInfoPresentationLogic {
    weak var viewController: KYCPersonalInfoDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentSetDateAndTaxID(response: KYCPersonalInfo.SetDateAndTaxID.Response) {
        viewController?.displaySetDateAndTaxID(viewModel: .init(date: response.date,
                                                                taxIdNumber: response.taxIdNumber))
    }
    
    func presentGetDataForPickerView(response: KYCPersonalInfo.GetDataForPickerView.Response) {
        switch response.type {
        case .date:
            viewController?.displayGetDataForPickerView(viewModel: .init(date: response.date,
                                                                         type: response.type))
            
        default:
            break
        }
    }
    
    func presentSetPickerValue(response: KYCPersonalInfo.SetPickerValue.Response) {
        viewController?.displaySetPickerValue(viewModel: .init(viewModel: .init(date: response.date,
                                                                                taxIdNumber: nil)))
    }
    
    func presentShouldEnableSubmit(response: KYCPersonalInfo.ShouldEnableSubmit.Response) {
        viewController?.displayShouldEnableSubmit(viewModel: .init(shouldEnable: response.shouldEnable))
    }
    
    func presentValidateField(response: KYCPersonalInfo.ValidateField.Response) {
        viewController?.displayValidateField(viewModel: .init(isFieldEmpty: response.isFieldEmpty,
                                                              type: response.type))
    }
}
