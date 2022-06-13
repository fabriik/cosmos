// 
//  KYCSubmitWorker.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class KYCSubmitWorker: BasePlainResponseWorker {

    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.submit)
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
