// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum KYCForgotPassword {
    // MARK: Model name declarations
    
    enum FieldType: Codable {
        case email
    }
    
    enum CheckFieldText {
        struct Request {
            let text: String?
            let type: KYCForgotPassword.FieldType
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
            let type: KYCForgotPassword.FieldType
        }
        
        struct ViewModel {
            let isViable: Bool
            let type: KYCForgotPassword.FieldType
        }
    }
}
