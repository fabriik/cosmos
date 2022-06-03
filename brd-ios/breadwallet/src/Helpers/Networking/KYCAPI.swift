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
    case countries = "countries"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

enum KYCAuthEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/one/%@"
    
    case register = "auth/associate"
    case login
    case confirm = "auth/associate/confirm"
    case resend = "auth/associate/resend"
    case startResetPassword = "password/start"
    case acceptResetPassword = "password/accept"
    case basic = "kyc/basic"

    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

class KYCBaseResponseWorker<T: ModelResponse, U: Model, V: ModelMapper<T, U>>: BaseResponseWorker<T, U, V> {}

class KYCBasePlainResponseWorker: BasePlainResponseWorker {}
