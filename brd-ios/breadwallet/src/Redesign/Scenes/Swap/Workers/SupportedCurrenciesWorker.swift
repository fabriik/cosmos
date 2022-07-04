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
        return SwapEndpoints.supportedCurrencies.url
    }
}
