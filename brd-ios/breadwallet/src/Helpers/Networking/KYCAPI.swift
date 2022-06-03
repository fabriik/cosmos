// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

enum KYCEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/one/kyc/%@"
    
    case personalInformation = "pi?%@"
    case uploadSelfieImage = "upload?type=SELFIE&%@"
    case uploadFrontBackImage = "upload?type=ID&%@"
    case login = "auth/login%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

enum KYCAuthEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/one/auth/%@"
    
    case register = "associate"
    case login
    case confirm = "associate/confirm"
    case resend = "associate/resend"
    case startResetPassword = "password/start"
    case acceptResetPassword = "password/accept"
    case basic = "one/kyc/basic"

    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

class KYCBaseResponseWorker<T: ModelResponse, U: Model, V: ModelMapper<T, U>>: BaseResponseWorker<T, U, V> {}

class KYCBasePlainResponseWorker: BasePlainResponseWorker {}
