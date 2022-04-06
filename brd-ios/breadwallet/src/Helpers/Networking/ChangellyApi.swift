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
    var lockedFromCurrency: String?
    var lockedToCurrency: String?
    
    var amount: Double = 1
    var address: String?
    
    var preselectedFromCurrency: String?
    var preselectedToCurrency: String?
    
    var theme: String = "default"
    var merchantId: String
    var paymentId: String?
    // not sure what this does
    var version: Int = 3
    
    init(from: Currency?, to: Currency?, amount: Double = 1, merchantId: String) {
        // uncommenting these, prevents currency selection (locks currencies)
//        lockedFromCurrency = from?.code.lowercased()
//        lockedToCurrency = to?.code.lowercased()
        
        self.amount = amount
        
        preselectedFromCurrency = from?.code.lowercased()
        preselectedToCurrency = to?.code.lowercased()
        self.merchantId = merchantId
    }
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "from": lockedFromCurrency,
            "to": lockedToCurrency,
            "amount": amount,
            "address": address,
            "fromDefault": preselectedFromCurrency,
            "toDefault": preselectedToCurrency,
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
    
    case swap(from: Currency, amount: Double, to: Currency)
    
    var requestData: SwapRequestData? {
        switch self {
        case .swap(let from, let amount, let to):
            return .init(from: from, to: to, amount: amount, merchantId: Self.merchantId)
        }
    }
    
    var url: String {
        return Self.baseUrl
    }
}
