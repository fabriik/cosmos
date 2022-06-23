//
// Created by Equaleyes Solutions Ltd
//

import Foundation

enum WyreEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/wyre/%@"
    
    case reserve = "reserve?test=%@&sessionKey=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

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
        let key: String
        
        if UserDefaults.kycSessionKeyValue == nil,
           let token = UserDefaults.walletTokenValue {
            key = token
        } else {
            key = "no_key"
        }
        
        return [
            "test": String(test),
            "sessionKey": key
        ]
    }
}

class ReservationWorker: BaseResponseWorker<ReservationResponseData, ReservationData, ReservationMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? ReservationRequestData) else { return "" }
        
        let params = urlParams.getParameters().compactMap { $0.value as? String }
        return APIURLHandler.getUrl(WyreEndpoints.reserve, parameters: params)
    }
}
