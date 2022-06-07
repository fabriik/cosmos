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

// TODO: BE bug.. currently the EP returns nil
struct ProfileResponseData: ModelResponse {
    var email: String?
    var kyc_status: String?
}

struct Profile: Model {
    var email: String?
    var status: VerificationStatus
}

class ProfileMapper: ModelMapper<ProfileResponseData, Profile> {
    override func getModel(from response: ProfileResponseData) -> Profile? {
        return .init(email: response.email, status: .init(rawValue: response.kyc_status))
    }
}

struct ProfileRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class ProfileWorker: BaseResponseWorker<ProfileResponseData, Profile, ProfileMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.profile)
    }
}
