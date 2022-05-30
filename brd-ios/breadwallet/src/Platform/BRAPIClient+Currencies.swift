//
//  BRAPIClient+Currencies.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-03-12.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import Foundation
import UIKit

public enum APIResult<ResultType: Codable> {
    case success(ResultType)
    case error(Error)
}

public struct HTTPError: Error {
    let code: Int
}

struct FiatCurrency: Decodable {
    var name: String
    var code: String
    
    static var availableCurrencies: [FiatCurrency] = {
        guard let path = Bundle.main.path(forResource: "fiatcurrencies", ofType: "json") else {
            print("unable to locate currencies file")
            return []
        }
        
        var currencies: [FiatCurrency]?
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            currencies = try decoder.decode([FiatCurrency].self, from: data)
        } catch let e {
            print("error parsing fiat currency data: \(e)")
        }
        
        return currencies ?? []
    }()
    
    // case of code doesn't matter
    static func isCodeAvailable(_ code: String) -> Bool {
        let available = FiatCurrency.availableCurrencies.map { $0.code.lowercased() }
        return available.contains(code.lowercased())
    }

}

extension BRAPIClient {
    /// Get the list of supported currencies and their metadata from the backend or local cache
    func getCurrencyMetaData(completion: @escaping ([CurrencyId: CurrencyMetaData]) -> Void) {
        guard let cachedFilePath = CurrencyFileManager.sharedCurrenciesFilePath else { return }
        
        var req = URLRequest(url: url("/currencies"))
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        send(request: req, handler: { (result: APIResult<[CurrencyMetaData]>) in
            switch result {
            case .success(let currencies):
                // update cache
                do {
                    let data = try JSONEncoder().encode(currencies)
                    try data.write(to: URL(fileURLWithPath: cachedFilePath))
                } catch let e {
                    print("[CurrencyList] Failed to write to cache: \(e.localizedDescription)")
                }
                
                CurrencyFileManager.processCurrencies(currencies, completion: completion)
                
            case .error(let error):
                print("[CurrencyList] Rrror fetching tokens: \(error)")
                CurrencyFileManager.copyEmbeddedCurrencies(path: cachedFilePath)
                
                let result = CurrencyFileManager.processCurrenciesCache(path: cachedFilePath, completion: completion)
                assert(result, "[CurrencyList] Failed to get currency list from backend or cache")
            }
        })
    }
    
    private func send<ResultType>(request: URLRequest, handler: @escaping (APIResult<ResultType>) -> Void) {
        dataTaskWithRequest(request, authenticated: true, retryCount: 0, handler: { data, response, error in
            guard error == nil, let data = data else {
                print("[API] HTTP error: \(error!)")
                return handler(APIResult<ResultType>.error(error!))
            }
            guard let statusCode = response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                return handler(APIResult<ResultType>.error(HTTPError(code: response?.statusCode ?? 0)))
            }
            
            do {
                let result = try JSONDecoder().decode(ResultType.self, from: data)
                handler(APIResult<ResultType>.success(result))
            } catch let jsonError {
                print("[API] JSON error: \(jsonError)")
                handler(APIResult<ResultType>.error(jsonError))
            }
        }).resume()
    }
}
