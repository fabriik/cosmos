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

enum ChangellyApi {
    static var baseUrl = "https://widget.changelly.com"
    static var merchantId = "NGVQYXnFp13iKtj1"
    
    case swap(from: Currency, amount: Double, to: Currency)
    
    var value: String {
        switch self {
        case .swap(let from, let amount, let to):
            return "?from=\(from.code)"
            + "&to=\(to.code)"
            + "&amount=\(amount)"
            + "&address="
            + "&fromDefault=\(from.code.lowercased())"
            + "&toDefault=\(to.code.lowercased())"
            + "&theme=default"
            + "&merchant_id=\(Self.merchantId)"
            + "&payment_id=&v=3"
        }
    }
    
    var url: String {
        return Self.baseUrl + value
    }
}
