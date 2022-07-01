// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

enum KYCEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/one/kyc/%@"
    
    case KYCBasicrmation = "pi?%@"
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
    
    case newDevice = "auth/new-device"
    case profile = "auth/profile"
    case register = "auth/associate"
    case confirm = "auth/associate/confirm"
    case resend = "auth/associate/resend"
    
    case basic = "kyc/basic"
    case documents = "kyc/documents"
    case upload = "kyc/upload"
    case submit = "kyc/session/submit"
    
    // TODO: @Kenan deprecated?
    case login
    case startResetPassword = "password/start"
    case acceptResetPassword = "password/accept"

    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

class KYCBaseApiWorker<M: Mapper>: BaseApiWorker<M> {}

class KYCBasePlainResponseWorker: BasePlainResponseWorker {}
