// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct KYCPostPersonalInfoWorkerUrlModelData: UrlModelData {
    func urlParameters() -> [String] {
        let sessionKey: String = "sessionKey=\(UserDefaults.kycSessionKeyValue)"
        
        return [sessionKey]
    }
}

struct KYCPostPersonalInformationWorkerRequest: RequestModelData {
    let street: String?
    let city: String?
    let state: String?
    let zip: String?
    let country: String?
    let dateOfBirth: String?
    let taxIdNumber: String?
    
    func getParameters() -> [String: Any] {
        return [
            "street": street ?? "",
            "city": city ?? "",
            "state": state ?? "",
            "zip": zip ?? "",
            "country": country ?? "",
            "date_of_birth": dateOfBirth ?? "",
            "tax_id_number": taxIdNumber ?? ""
        ]
    }
}

struct KYCPostPersonalInformationWorkerData: RequestModelData, UrlModelData {
    let workerRequest: KYCPostPersonalInformationWorkerRequest
    let workerUrlModelData: KYCPostPersonalInfoWorkerUrlModelData
    
    func getParameters() -> [String: Any] {
        return workerRequest.getParameters()
    }
    
    func urlParameters() -> [String] {
        return workerUrlModelData.urlParameters()
    }
}

class KYCPostPersonalInformationWorker: KYCBasePlainResponseWorker {
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
