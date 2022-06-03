//
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct CountriesResponseData: ModelResponse {
    var data: [String: String]?
}

struct CountriesData: Model {
}

struct CountriesRequestData: RequestModelData {
    let locale: String = Locale.current.identifier
    let sessionKey: String = UserDefaults.kycSessionKeyValue
    
    func getParameters() -> [String: Any] {
        return [
            "_locale": locale,
            "sessionKey": sessionKey
        ]
    }
}

class CountriesWorker: BaseResponseWorker<CountriesResponseData,
                       CountriesData,
                       ModelMapper<CountriesResponseData, CountriesData>> {
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCEndpoints.countries)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .get
    }
}
