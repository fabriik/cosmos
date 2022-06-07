//
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct CountryResponseData: ModelResponse {
    var iso2: String?
    var localizedName: String?
}

struct CountriesResponseData: ModelResponse {
    // TODO: replace "countries" with the actual key that the BE will return
    var countries: [CountryResponseData]
}

class CountriesMapper: ModelMapper<CountriesResponseData, [String]> {
    override func getModel(from response: CountriesResponseData) -> [String]? {
        return response.countries.compactMap { $0.iso2 }
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

class CountriesWorker: BaseResponseWorker<CountriesResponseData,
                       [String],
                       CountriesMapper> {
    
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
