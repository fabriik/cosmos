// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum KYCResetPassword {
    // MARK: Model name declarations
    
    enum FieldType: Codable {
        case recoveryCode
        case password
        case passwordRepeat
    }
    
    enum CheckFieldText {
        struct Request {
            let text: String?
            let type: KYCResetPassword.FieldType
        }
    }
    
    enum ShouldEnableConfirm {
        struct Response {
            let shouldEnable: Bool
        }
        struct ViewModel {
            let shouldEnable: Bool
        }
    }
    
    enum SubmitData {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
    
    enum ValidateField {
        struct Response {
            let isViable: Bool
            let type: KYCResetPassword.FieldType
        }
        
        struct ViewModel {
            let isViable: Bool
            let type: KYCResetPassword.FieldType
        }
    }
}
