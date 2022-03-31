// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCAddressPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentGetDataForPickerView(response: KYCAddress.GetDataForPickerView.Response)
    func presentSetPickerValue(response: KYCAddress.SetPickerValue.Response)
    func presentSubmitData(response: KYCAddress.SubmitData.Response)
    func presentError(response: GenericModels.Error.Response)
}

class KYCAddressPresenter: KYCAddressPresentationLogic {
    weak var viewController: KYCAddressDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentGetDataForPickerView(response: KYCAddress.GetDataForPickerView.Response) {
        let countryTitleValues = KYCConstants.Countries.names
        let countryCodes = KYCConstants.Countries.codes
        
        let usaStatesTitleValues = KYCConstants.USAStates.names
        let usaStatesCodes = KYCConstants.USAStates.codes
        
        switch response.type {
        case .country:
            viewController?.displayGetDataForPickerView(viewModel: .init(index: response.index,
                                                                         pickerValues: countryTitleValues,
                                                                         fieldValues: countryCodes,
                                                                         type: response.type))
            
        case .state:
            viewController?.displayGetDataForPickerView(viewModel: .init(index: response.index,
                                                                         pickerValues: usaStatesTitleValues,
                                                                         fieldValues: usaStatesCodes,
                                                                         type: response.type))
            
        default:
            break
        }
    }
    
    func presentSetPickerValue(response: KYCAddress.SetPickerValue.Response) {
        viewController?.displaySetPickerValue(viewModel: .init(viewModel: .init(country: response.country,
                                                                                zipCode: nil,
                                                                                address: nil,
                                                                                apartment: nil,
                                                                                state: response.state)))
    }
    
    func presentSubmitData(response: KYCAddress.SubmitData.Response) {
        viewController?.displaySubmitData(viewModel: .init())
    }
    
    func presentError(response: GenericModels.Error.Response) {
        viewController?.displayError(viewModel: .init(error: response.error?.errorMessage ?? ""))
    }
}
