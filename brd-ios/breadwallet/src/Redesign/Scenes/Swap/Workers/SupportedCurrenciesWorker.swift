// 
//  SupportedCurrenciesWorker.swift
//  breadwallet
//
//  Created by Rok on 04/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

//"base_currency": "SHIB",
//"term_currency": "USDT",
//"minimum_quantity": 0.001,
//"maximum_quantity": 1000000,
//"name": "SHIB-USDT"

struct SupportedCurrenciesResponseData: ModelResponse {
    struct SupportedCurrencyResponseData: ModelResponse {
        var baseCurrency: String
        var termCurrency: String
        var minimumQuantity: Double
        var maximumQuantity: Double
        var name: String
    }
    
    var tradingPairs: [SupportedCurrencyResponseData]
}

struct SupportedCurrency {
    var baseCurrency: String
    var termCurrency: String
    var minimumQuantity: Double
    var maximumQuantity: Double
    var name: String
}

class SupportedCurrenciesWorkerMapper: ModelMapper<SupportedCurrenciesResponseData, [SupportedCurrency]> {
    override func getModel(from response: SupportedCurrenciesResponseData?) -> [SupportedCurrency]? {
        return response?.tradingPairs.compactMap { return .init(baseCurrency: $0.baseCurrency,
                                                                termCurrency: $0.termCurrency,
                                                                minimumQuantity: $0.minimumQuantity,
                                                                maximumQuantity: $0.maximumQuantity,
                                                                name: $0.name) }
    }
}

class SupportedCurrenciesWorker: BaseApiWorker<SupportedCurrenciesWorkerMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.supportedCurrencies.url
    }
}

enum ExchangeEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/exchange/%@"
    
    case supportedCurrencies = "supported-currencies"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
