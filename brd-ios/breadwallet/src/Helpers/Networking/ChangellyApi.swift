// 
//  ChangellyApi.swift
//  breadwallet
//
//  Created by Rok on 06/04/2022.
//  Copyright © 2022 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SwapRequestData: RequestModelData {
    var currencyCodes: [String]
    var amount: Double = 1
    var address: String?
    
    var preselectedFromCurrency: String?
    var preselectedToCurrency: String?
    
    var theme: String = "default"
    var merchantId: String
    var paymentId: String?
    // not sure what this does
    var version: Int = 3
    
    init(currencies: [Currency] = [], amount: Double = 1, merchantId: String) {
        currencyCodes = currencies.compactMap { $0.code.lowercased() }
        self.amount = amount
        self.merchantId = merchantId
    }
    
    func getParameters() -> [String: Any] {
        let codesString = currencyCodes.joined(separator: ",")
        let params: [String: Any?] = [
            "from": codesString,
            "to": codesString,
            "amount": amount,
            "address": address,
            "fromDefault": "btc",
            "toDefault": "eth",
            "theme": theme,
            "merchantId": merchantId,
            "payment_id": paymentId,
            "v": version
        ]

        return params.compactMapValues { $0 }
    }
}

enum ChangellyApi {
    static var baseUrl = "https://widget.changelly.com"
    static var merchantId = "NGVQYXnFp13iKtj1"
    
    case swap(currencies: [Currency], amount: Double)
    
    var requestData: SwapRequestData? {
        switch self {
        case .swap(let currencies, let amount):
            return .init(currencies: currencies, amount: amount, merchantId: Self.merchantId)
        }
    }
    
    var url: String {
        return Self.baseUrl
    }
}
