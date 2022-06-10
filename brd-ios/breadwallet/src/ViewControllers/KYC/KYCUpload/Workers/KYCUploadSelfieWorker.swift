// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct KYCUploadSelfieWorkerUrlModelData: UrlModelData {
    func urlParameters() -> [String] {
        let sessionKey: String = "sessionKey=\(UserDefaults.kycSessionKeyValue)"
        
        return [sessionKey]
    }
}

struct KYCUploadSelfieWorkerRequest: RequestModelData {
    let imageData: [KYCUploadViewController.Step: Data]
    
    func getParameters() -> [String: Any] {
        guard let selfieData = imageData[.idSelfie] else { return [:] }
        
        let value = [KYCUploadFrontBackWorker.frontKey: selfieData]
        
        return value
    }
}

struct KYCUploadSelfieWorkerData: RequestModelData, UrlModelData {
    let workerRequest: KYCUploadSelfieWorkerRequest
    let workerUrlModelData: KYCUploadSelfieWorkerUrlModelData
    
    func getParameters() -> [String: Any] {
        return workerRequest.getParameters()
    }
    
    func urlParameters() -> [String] {
        return workerUrlModelData.urlParameters()
    }
}

class KYCUploadSelfieWorker: KYCBasePlainResponseWorker {
    
    override func getUrl() -> String {
        guard let urlParams = (requestData as? KYCUploadSelfieWorkerData)?.urlParameters() else { return "" }
        
        return APIURLHandler.getUrl(KYCEndpoints.uploadSelfieImage, parameters: urlParams)
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
    
    override func getMultipartData() -> [MultipartMedia] {
        guard let getParameters = (requestData as? KYCUploadSelfieWorkerData)?.getParameters(),
              let selfieValue = getParameters[KYCUploadFrontBackWorker.frontKey] as? Data else { return [] }
        
        return [
            .init(with: selfieValue,
                  fileName: UUID().uuidString,
                  forKey: KYCUploadFrontBackWorker.frontKey,
                  mimeType: .jpeg,
                  mimeFileFormat: .jpeg)
        ]
    }
}
