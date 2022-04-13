//
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct WyreReservationResponseObject: ModelResponse {
    var url: String?
    var reservation: String?
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
