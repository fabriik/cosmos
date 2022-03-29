// 
//  WyreReservationWorker.swift
//  breadwallet
//
//  Created by Rok on 29/03/2022.
//  Copyright © 2022 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct WyreReservationResponseObject: ModelResponse {
    var code: String?
}

struct WyreReservationRequest: ExternalAPIRequest {
    typealias Response = WyreReservationResponseObject
    var hostName: String { return "https://" + E.apiUrl + "blocksatoshi/" }
    var resourceName: String { return "wyre/reserve?test=\(isTest)&sessionKey=\(sessionKey)" }
    
    let sessionKey = E.apiToken
    #if DEBUG
    let isTest = true
    #else
    let isTest = false
    #endif
}
