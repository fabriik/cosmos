// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct KYCResetPasswordWorkerUrlModelData: UrlModelData {
    func urlParameters() -> [String] {
        return []
    }
}

struct KYCResetPasswordWorkerRequest: RequestModelData {
    let key: String?
    let password: String?
    
    func getParameters() -> [String: Any] {
        return [
            "key": key ?? "",
            "password": password ?? ""
        ]
    }
}

struct KYCResetPasswordWorkerData: RequestModelData, UrlModelData {
    let workerRequest: KYCResetPasswordWorkerRequest
    let workerUrlModelData: KYCResetPasswordWorkerUrlModelData
    
    func getParameters() -> [String: Any] {
        return workerRequest.getParameters()
    }
    
    func urlParameters() -> [String] {
        return workerUrlModelData.urlParameters()
    }
}

class KYCResetPasswordWorker: KYCBasePlainResponseWorker {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? KYCResetPasswordWorkerData)?.urlParameters() else { return "" }
        
        return APIURLHandler.getUrl(KYCAuthEndpoints.acceptResetPassword, parameters: urlParams)
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
