//
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct CountryResponseData: ModelResponse {
    var iso2: String?
    var localizedName: String?
}

struct CountriesResponseData: ModelResponse {
    var countries: [CountryResponseData]
}

class CountriesMapper: ModelMapper<CountriesResponseData, [CountryResponseData]> {
    override func getModel(from response: CountriesResponseData) -> [CountryResponseData]? {
        return response.countries
    }
}

struct CountriesRequestData: RequestModelData {
    let locale: String = Locale.current.identifier
    
    func getParameters() -> [String: Any] {
        return [
            "_locale": locale
        ]
    }
}

class CountriesWorker: BaseApiWorker<CountriesMapper> {
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCEndpoints.countries)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .get
    }
}
