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
        guard let sharedCachedFilePath = CurrencyFileManager.sharedCachedFilePath else { return }
        
        var shouldProcess = true
        // If cache isn't expired, use cached data and return before the network call
        if !CurrencyFileManager.isCacheExpired(path: sharedCachedFilePath, timeout: C.secondsInMinute*60*24) &&
            CurrencyFileManager.processCurrenciesCache(path: sharedCachedFilePath, completion: completion) {
            //Even if cache is used, we still want to update the local version
            shouldProcess = false
        }
        
        var req = URLRequest(url: url("/currencies"))
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        send(request: req, handler: { (result: APIResult<[CurrencyMetaData]>) in
            switch result {
            case .success(let currencies):
                // update cache
                do {
                    let data = try JSONEncoder().encode(currencies)
                    try data.write(to: URL(fileURLWithPath: sharedCachedFilePath))
                } catch let e {
                    print("[CurrencyList] failed to write to cache: \(e.localizedDescription)")
                }
                if shouldProcess {
                    CurrencyFileManager.processCurrencies(currencies, completion: completion)
                }
            case .error(let error):
                print("[CurrencyList] error fetching tokens: \(error)")
                CurrencyFileManager.copyEmbeddedCurrencies(path: sharedCachedFilePath)
                if shouldProcess {
                    let result = CurrencyFileManager.processCurrenciesCache(path: sharedCachedFilePath, completion: completion)
                    assert(result, "failed to get currency list from backend or cache")
                }
            }
        })
        
        CurrencyFileManager.cleanupOldTokensFile()
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
