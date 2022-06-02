// 
//  RegistrationWorker.swift
//  breadwallet
//
//  Created by Rok on 01/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

class RegistrationMapper: ModelMapper<RegistrationResponseData, RegistrationData> {
    override func getModel(from response: RegistrationResponseData) -> RegistrationData? {
        guard let key = response.sessionKey else {
            return nil
        }
        return .init(sessionKey: key)
    }
}

struct RegistrationResponseData: ModelResponse {
    var data: [String: String]?
    var sessionKey: String? {
        return data?["sessionKey"]
    }
}

struct RegistrationData: Model {
    var sessionKey: String?
}

struct RegistrationRequestData: RequestModelData {
    let email: String?
    let token: String?
    
    func getParameters() -> [String: Any] {
        return [
            "email": email ?? "",
            "token": token ?? ""
        ]
    }
}

class RegistrationWorker: BaseResponseWorker<RegistrationResponseData,
                          RegistrationData,
                          RegistrationMapper> {
    override func getHeaders() -> [String: String] {
        guard let email = (getParameters()["email"] as? String),
              let token = (getParameters()["token"] as? String),
              let data = (token + email).data(using: .utf8)?.sha256,
              let key = try? KeyStore.create().apiAuthKey,
              let signature = CoreSigner.basicDER.sign(data32: data, using: key)?.base64EncodedString()
        else { return [:] }
        
        // TODO: extract?
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "US")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = formatter.string(from: Date())
        
        return [
            "Date": dateString,
            "Signature": signature
        ]
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.register)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
