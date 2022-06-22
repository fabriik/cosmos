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
    var resourceName: String { return "wyre/reserve?test=\(E.isTest)&sessionKey=\(sessionKey)" }
    
    var sessionKey: String {
        let key = UserDefaults.kycSessionKeyValue
        
        if key.isEmpty,
           let token = UserDefaults.walletTokenValue {
            return token
        }
        
        return key
    }
}
