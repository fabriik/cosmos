// 
//  RegistrationConfirmationWorker.swift
//  breadwallet
//
//  Created by Rok on 01/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct RegistrationConfirmationResponseData: ModelResponse {
}

struct RegistrationConfirmationData: Model {
}

struct RegistrationConfirmationWorkerRequest: RequestModelData {
    let code: String?
    
    func getParameters() -> [String: Any] {
        return [
            "confirmation_code": code ?? ""
        ]
    }
}

class RegistrationConfirmationWorker: BaseResponseWorker<RegistrationConfirmationResponseData,
                                      RegistrationConfirmationData,
                                      ModelMapper<RegistrationConfirmationResponseData, RegistrationConfirmationData>> {

    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.confirm)
    }

    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }

    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
