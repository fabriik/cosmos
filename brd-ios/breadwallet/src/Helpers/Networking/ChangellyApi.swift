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
    var merchantId: String
    var paymentId: String?
    // not sure what this does
    var version: Int = 3
    var referalId = "qo738lc61vwk"
    
    init(currencies: [String] = [], amount: Double = 1, merchantId: String) {
        currencyCodes = currencies.compactMap { $0.lowercased() }
        self.amount = amount
        self.merchantId = merchantId
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
    static var merchantId = "NGVQYXnFp13iKtj1"
    
    case swap(currencies: [String], amount: Double)
    
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
