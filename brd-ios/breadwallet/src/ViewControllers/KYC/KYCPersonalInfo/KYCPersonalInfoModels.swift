// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum KYCPersonalInfo {
    // MARK: Model name declarations
    
    enum FieldType: Codable {
        case date
        case taxIdNumber
    }
    
    enum GetDataForPickerView {
        struct Request {
            let type: KYCPersonalInfo.FieldType
        }
        struct Response {
            let date: Date?
            let type: KYCPersonalInfo.FieldType
        }
        struct ViewModel {
            let date: Date?
            let type: KYCPersonalInfo.FieldType
        }
    }
    
    enum CheckFieldPickerIndex {
        struct Request {
            let selectedDate: Date
            let type: KYCPersonalInfo.FieldType
        }
    }
    
    enum SetPickerValue {
        struct Response {
            let date: String
        }
        struct ViewModel {
            let viewModel: KYCPersonalInfoView.ViewModel
        }
    }
    
    enum SetDateAndTaxID {
        struct Request {}
        struct Response {
            let date: String
            let taxIdNumber: String
        }
        struct ViewModel {
            let date: String
            let taxIdNumber: String
        }
    }
    
    enum CheckFieldText {
        struct Request {
            let text: String?
            let type: KYCPersonalInfo.FieldType
        }
    }
    
    enum ShouldEnableSubmit {
        struct Response {
            let shouldEnable: Bool
        }
        struct ViewModel {
            let shouldEnable: Bool
        }
    }
    
    enum ValidateField {
        struct Response {
            let isViable: Bool
            let type: KYCPersonalInfo.FieldType
            let isFieldEmpty: Bool
        }
        
        struct ViewModel {
            let isViable: Bool
            let type: KYCPersonalInfo.FieldType
            let isFieldEmpty: Bool
        }
    }
}
