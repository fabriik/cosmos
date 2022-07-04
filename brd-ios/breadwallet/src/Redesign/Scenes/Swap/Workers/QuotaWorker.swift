// 
//  QuotaWorker.swift
//  breadwallet
//
//  Created by Rok on 04/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct QuotaRequestData: RequestModelData {
    var sourceCurrency: String?
    var destinationCurrency: String?
    
    func getParameters() -> [String: Any] {
        return [
            "source_currency": sourceCurrency,
            "destination_currency": destinationCurrency
        ].compactMapValues { $0 }
    }
}

// TODO: map when call succeds
struct QuotaModelResponse: ModelResponse {}

struct Quota {}

class QuotaMapper: ModelMapper<QuotaModelResponse, Quota> {
    override func getModel(from response: QuotaModelResponse?) -> Quota? {
        return nil
    }
}

class QuotaWorker: BaseApiWorker<QuotaMapper> {
    override func getUrl() -> String {
        return SwapEndpoints.quota.url
    }
}
