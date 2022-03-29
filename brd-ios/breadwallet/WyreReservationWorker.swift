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

struct WyreReservation: Model {
    var code: String
}

struct WyreReservationRequest: RequestModelData {
    var isTest = false
    let sessionKey = E.apiToken
    
    func urlParameters() -> [String] {
        return [
            "test=\(isTest)",
            "sessionKey=\(sessionKey)"
        ]
    }
    
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class WyreReservationMapper: ModelMapper<WyreReservationResponseObject, WyreReservation> {
    override func getModel(from response: WyreReservationResponseObject) -> WyreReservation? {
        guard let code = response.code else {
            return nil
        }
        return .init(code: code)
    }
}

class WyreReservationWorker: BaseResponseWorker<WyreReservationResponseObject, WyreReservation, WyreReservationMapper> {
    override func getUrl() -> String {
        guard let data = requestData as? WyreReservationRequest else { fatalError() }
        return APIURLHandler.getUrl(WyreEndpoints.reserve, parameters: data.urlParameters())
    }
}
