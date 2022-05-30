// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct SwapRequestData: RequestModelData {
    var currencyCodes: [String]
    var amount: Double = 1
    var address: String?
    
    var preselectedFromCurrency: String?
    var preselectedToCurrency: String?
    
    var theme: String = "default"
    var merchantId = "LQKofuqAUxW87eKx"
    var paymentId: String?
    // not sure what this does
    var version: Int = 3
    var referalId = "m3RudWCT8RWVKSrp"
    
    init(currencies: [String] = [], amount: Double = 1) {
        currencyCodes = currencies.compactMap { $0.lowercased() }
        self.amount = amount
    }
    
    func getParameters() -> [String: Any] {
        let codesString = currencyCodes.map { value in
            guard value == "usdt" else { return value }
            // we support ERC20 usdt trading
            return value + "20"
        }.joined(separator: ",")
        
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
            "v": version,
            "ref_id": referalId
        ]

        return params.compactMapValues { $0 }
    }
}

enum ChangellyApi {
    static var baseUrl = "https://widget.changelly.com"
    
    case swap(currencies: [String], amount: Double)
    
    var requestData: SwapRequestData? {
        switch self {
        case .swap(let currencies, let amount):
            return .init(currencies: currencies, amount: amount)
        }
    }
    
    var url: String {
        return Self.baseUrl
    }
}
