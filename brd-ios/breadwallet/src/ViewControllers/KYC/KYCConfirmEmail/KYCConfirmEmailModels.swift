//
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum KYCConfirmEmail {
    // MARK: Model name declarations
    
    enum FieldType: Codable {
        case code
    }
    
    enum CheckFieldText {
        struct Request {
            let text: String?
            let type: KYCConfirmEmail.FieldType
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
    
    enum ShouldResendCode {
        struct Request {}
    }
    
    enum ResendCode {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
    
    enum ValidateField {
        struct Response {
            let isViable: Bool
        }
        
        struct ViewModel {
            let isViable: Bool
        }
    }
}
