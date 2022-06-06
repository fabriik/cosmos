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
struct ProfileResponseData: ModelResponse {}

struct Profile: Model {
    var status: VerificationStatus = .none
}

struct ProfileRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class ProfileWorker: BaseResponseWorker<ProfileResponseData, Profile, ModelMapper<ProfileResponseData, Profile>> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.profile)
    }
}
