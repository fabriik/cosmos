// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCPersonalInfoBusinessLogic {
    // MARK: Business logic functions
    
    func executeSetDateAndTaxID(request: KYCPersonalInfo.SetDateAndTaxID.Request)
    func executeGetDataForPickerView(request: KYCPersonalInfo.GetDataForPickerView.Request)
    func executeCheckFieldPickerIndex(request: KYCPersonalInfo.CheckFieldPickerIndex.Request)
    func executeCheckFieldType(request: KYCPersonalInfo.CheckFieldText.Request)
}

protocol KYCPersonalInfoDataStore {
    // MARK: Data store
    
    var date: String? { get set }
    var taxIdNumber: String? { get set }
    
    var selectedCurrentDate: Date? { get set }
}

class KYCPersonalInfoInteractor: KYCPersonalInfoBusinessLogic, KYCPersonalInfoDataStore {
    var presenter: KYCPersonalInfoPresentationLogic?
    
    // MARK: Interactor functions
    
    var date: String?
    var taxIdNumber: String?
    
    var selectedCurrentDate: Date?
    
    func executeSetDateAndTaxID(request: KYCPersonalInfo.SetDateAndTaxID.Request) {
        presenter?.presentSetDateAndTaxID(response: .init(date: date ?? "",
                                                          taxIdNumber: taxIdNumber ?? ""))
    }
    
    func executeGetDataForPickerView(request: KYCPersonalInfo.GetDataForPickerView.Request) {
        switch request.type {
        case .date:
            presenter?.presentGetDataForPickerView(response: .init(date: selectedCurrentDate,
                                                                   type: request.type))
            
        default:
            break
            
        }
    }
    
    func executeCheckFieldPickerIndex(request: KYCPersonalInfo.CheckFieldPickerIndex.Request) {
        let selectedDate = request.selectedDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDateString = formatter.string(from: selectedDate)
        
        switch request.type {
        case .date:
            date = formattedDateString
            selectedCurrentDate = selectedDate
            
        default:
            break
        }
        
        presenter?.presentSetPickerValue(response: .init(date: date ?? ""))
        
        checkCredentials()
    }
    
    func executeCheckFieldType(request: KYCPersonalInfo.CheckFieldText.Request) {
        switch request.type {
        case .taxIdNumber:
            taxIdNumber = request.text
            
        default:
            break
        }
        
        checkCredentials()
    }
    
    private func checkCredentials() {
        var validationValues = [Bool]()
        validationValues.append(!date.isNilOrEmpty)
        validationValues.append(!taxIdNumber.isNilOrEmpty)
        validationValues.append(validateDate())
        validationValues.append(validateTaxIdNumber())
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableSubmit(response: .init(shouldEnable: shouldEnable))
    }
    
    private func validateDate() -> Bool {
        let isFieldEmpty = (date ?? "").isEmpty
        
        presenter?.presentValidateField(response: .init(isViable: !isFieldEmpty, isFieldEmpty: isFieldEmpty, type: .date))
        
        return isFieldEmpty
    }
    
    private func validateTaxIdNumber() -> Bool {
        let isFieldEmpty = (taxIdNumber ?? "").isEmpty
        
        presenter?.presentValidateField(response: .init(isViable: !isFieldEmpty, isFieldEmpty: isFieldEmpty, type: .taxIdNumber))
        
        return isFieldEmpty
    }
}
