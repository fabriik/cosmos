// 
//  ProfileWorker.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ProfileResponseData: ModelResponse {
    var country: String?
    var date_of_birth: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var kyc_status: String?
    var kyc_failure_reason: String?
}

struct Profile: Model {
    var country: String?
    var dateOfBirth: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var status: VerificationStatus
    var failureReason: String?
}

class ProfileMapper: ModelMapper<ProfileResponseData, Profile> {
    override func getModel(from response: ProfileResponseData?) -> Profile? {
        return .init(country: response?.country,
                     dateOfBirth: response?.date_of_birth,
                     firstName: response?.first_name,
                     lastName: response?.last_name,
                     email: response?.email,
                     status: .init(rawValue: response?.kyc_status),
                     failureReason: response?.kyc_failure_reason)
    }
}

struct ProfileRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class ProfileWorker: BaseApiWorker<ProfileMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.profile)
    }
}
