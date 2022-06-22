//
// Created by Equaleyes Solutions Ltd
//

import Foundation

class ReservationMapper: ModelMapper<ReservationResponseData, ReservationData> {
    override func getModel(from response: ReservationResponseData) -> ReservationData? {
        return .init(url: response.url, reservation: response.reservation)
    }
}

struct ReservationResponseData: ModelResponse {
    var url: String?
    var reservation: String?
}

struct ReservationData: Model {
    var url: String?
    var reservation: String?
}

struct ReservationRequestData: RequestModelData {
    let test: Bool = E.isTest
    let sessionKey: String = E.apiToken
    
    func getParameters() -> [String: Any] {
        var key = UserDefaults.kycSessionKeyValue

        if key.isEmpty,
           let token = UserDefaults.walletTokenValue {
            key = token
        }
        return [
            "test": test,
            "sessionKey": key
        ]
    }
}

class ReservationWorker: BaseResponseWorker<ReservationResponseData, ReservationData, ReservationMapper> {
    override func getUrl() -> String {
        let params = getParameters()
        let isTest = (params["test"] as? Bool) ?? false
        let sessionKey = (params["sessionKey"] as? String) ?? ""
        return "https://\(E.apiUrl)blocksatoshi/wyre/reserve?test=\(isTest)&sessionKey=\(sessionKey)"
    }
    
    override func getHeaders() -> [String: String] {
        return [:]
    }
}
