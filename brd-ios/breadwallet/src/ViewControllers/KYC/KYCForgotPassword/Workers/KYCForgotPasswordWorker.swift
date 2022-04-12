// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct KYCForgotPasswordWorkerUrlModelData: UrlModelData {
    func urlParameters() -> [String] {
        return []
    }
}

struct KYCForgotPasswordWorkerRequest: RequestModelData {
    let email: String?
    
    func getParameters() -> [String: Any] {
        return [
            "username": email ?? ""
        ]
    }
}

struct KYCForgotPasswordWorkerData: RequestModelData, UrlModelData {
    let workerRequest: KYCForgotPasswordWorkerRequest
    let workerUrlModelData: KYCForgotPasswordWorkerUrlModelData
    
    func getParameters() -> [String: Any] {
        return workerRequest.getParameters()
    }
    
    func urlParameters() -> [String] {
        return workerUrlModelData.urlParameters()
    }
}

class KYCForgotPasswordWorker: KYCBasePlainResponseWorker {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? KYCForgotPasswordWorkerData)?.urlParameters() else { return "" }
        
        return APIURLHandler.getUrl(KYCAuthEndpoints.startResetPassword, parameters: urlParams)
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
