// 
//  Currency+Shared.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

public enum AppGroup: String {
    case fabriikOne = "group.com.fabriik.one"
    
    public var containerURL: URL? {
        switch self {
        case .fabriikOne:
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: rawValue)
        }
    }
}

protocol CurrencyWithIcon {
    var code: String { get }
    var colors: (UIColor, UIColor) { get }
}

protocol CurrencyUID {
    var isBitcoin: Bool { get }
    var isBitcoinSV: Bool { get }
    var isBitcoinCash: Bool { get }
    var isEthereum: Bool { get }
    var isERC20Token: Bool { get }
    var isBRDToken: Bool { get }
    var isXRP: Bool { get }
    var isHBAR: Bool { get }
    var isBitcoinCompatible: Bool { get }
    var isEthereumCompatible: Bool { get }
    var isTezos: Bool { get }
    
    var uid: CurrencyId { get }
    var name: String { get }
    var tokenType: SharedCurrency.TokenType { get }
    var coinGeckoId: String? { get }
    var colors: (UIColor, UIColor) { get }
    var code: String { get }
    var isSupported: Bool { get }
}

typealias CurrencyId = Identifier<Currency>
typealias AssetCodes = Currencies.AssetCodes

class SharedCurrency: CurrencyUID {
    public enum TokenType: String {
        case native
        case erc20
        case unknown
    }
    
    /// Unique identifier from BlockchainDB
    var uid: CurrencyId { return .init(rawValue: "") }
    
    /// Display name (e.g. Bitcoin)
    var name: String { return "" }
    
    var tokenType: TokenType { return .unknown }
    
    var coinGeckoId: String? { return "" }
    
    /// Primary + secondary color
    var colors: (UIColor, UIColor) { return (.clear, .clear) }
    
    var code: String { return "" }
    
    /// False if a token has been delisted, true otherwise
    var isSupported: Bool { return false }
    
    var isBitcoin: Bool { return uid == Currencies.shared.getUID(from: AssetCodes.btc.value) }
    var isBitcoinSV: Bool { return uid == Currencies.shared.getUID(from: AssetCodes.bsv.value) }
    var isBitcoinCash: Bool { return uid == Currencies.shared.getUID(from: AssetCodes.bch.value) }
    var isEthereum: Bool { return uid == Currencies.shared.getUID(from: AssetCodes.eth.value) }
    var isXRP: Bool { return uid == Currencies.shared.getUID(from: AssetCodes.xrp.value) }
    var isERC20Token: Bool { return tokenType == .erc20 }
    var isBitcoinCompatible: Bool { return isBitcoin || isBitcoinCash }
    var isEthereumCompatible: Bool { return isEthereum || isERC20Token }
    
    // Unused
    var isBRDToken: Bool { return uid == Currencies.shared.getUID(from: "brd") }
    var isHBAR: Bool { return uid == Currencies.shared.getUID(from: "hbar")}
    var isTezos: Bool { return uid == Currencies.shared.getUID(from: "xtz") }
    
    init() {}
}

// MARK: - Metadata Model

/// Model representing metadata for supported currencies
public struct CurrencyMetaData: CurrencyWithIcon {
    let uid: CurrencyId
    let code: String
    let isSupported: Bool
    let colors: (UIColor, UIColor)
    let name: String
    var tokenAddress: String?
    var decimals: UInt8
    let type: String
    
    var isPreferred: Bool {
        return Currencies.shared.currencies.map { $0.uid }.contains(uid)
    }
    
    var alternateCode: String?
    var coinGeckoId: String?
    
    enum CodingKeys: String, CodingKey {
        case uid = "currency_id"
        case code
        case isSupported = "is_supported"
        case colors
        case tokenAddress = "contract_address"
        case name
        case decimals = "scale"
        case alternateNames = "alternate_names"
        case type
    }
}

extension CurrencyMetaData: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //TODO:CRYPTO temp hack until testnet support to added /currencies endpoint (BAK-318)
        var uid = try container.decode(String.self, forKey: .uid)
        if E.isTestnet {
            uid = uid.replacingOccurrences(of: "mainnet", with: "testnet")
            uid = uid.replacingOccurrences(of: "0x558ec3152e2eb2174905cd19aea4e34a23de9ad6", with: "0x7108ca7c4718efa810457f228305c9c71390931a") // BRD token
            uid = uid.replacingOccurrences(of: "ethereum-testnet", with: "ethereum-goerli")
        }
        self.uid = CurrencyId(rawValue: uid) //try container.decode(CurrencyId.self, forKey: .uid)
        code = try container.decode(String.self, forKey: .code)
        let colorValues = try container.decode([String].self, forKey: .colors)
        if colorValues.count == 2 {
            colors = (UIColor.fromHex(colorValues[0]), UIColor.fromHex(colorValues[1]))
        } else {
            if E.isDebug {
                throw DecodingError.dataCorruptedError(forKey: .colors, in: container, debugDescription: "Invalid/missing color values")
            }
            colors = (UIColor.black, UIColor.black)
        }
        isSupported = try container.decode(Bool.self, forKey: .isSupported)
        name = try container.decode(String.self, forKey: .name)
        tokenAddress = try container.decode(String.self, forKey: .tokenAddress)
        decimals = try container.decode(UInt8.self, forKey: .decimals)
        
        let type = try container.decode(String.self, forKey: .type)
        self.type = type != SharedCurrency.TokenType.erc20.rawValue ? SharedCurrency.TokenType.native.rawValue : SharedCurrency.TokenType.erc20.rawValue
        
        var didFindCoinGeckoID = false
        if let alternateNames = try? container.decode([String: String].self, forKey: .alternateNames) {
            if let code = alternateNames["cryptocompare"] {
                alternateCode = code
            }
            
            if let id = alternateNames["coingecko"] {
                didFindCoinGeckoID = true
                coinGeckoId = id
            }
        }
        
        // If the /currencies endpoint hasn't provided a coingeckoID,
        // use the local list. Eventually /currencies should provide
        // all of them
        if !didFindCoinGeckoID {
            if let id = CoinGeckoCodes.map[code.uppercased()] {
                coinGeckoId = id
            } else if code.uppercased() == "BSV" {
                coinGeckoId = "bitcoin-cash-sv"
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(code, forKey: .code)
        var colorValues = [String]()
        colorValues.append(colors.0.toHex)
        colorValues.append(colors.1.toHex)
        try container.encode(colorValues, forKey: .colors)
        try container.encode(isSupported, forKey: .isSupported)
        try container.encode(name, forKey: .name)
        try container.encode(tokenAddress, forKey: .tokenAddress)
        try container.encode(type, forKey: .type)
        try container.encode(decimals, forKey: .decimals)
        
        var alternateNames = [String: String]()
        if let alternateCode = alternateCode {
            alternateNames["cryptocompare"] = alternateCode
        }
        if let coingeckoId = coinGeckoId {
            alternateNames["coingecko"] = coingeckoId
        }
        if !alternateNames.isEmpty {
            try container.encode(alternateNames, forKey: .alternateNames)
        }
    }
}

extension CurrencyMetaData: Hashable {
    public static func == (lhs: CurrencyMetaData, rhs: CurrencyMetaData) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

class Currencies {
    static var shared = Currencies()
    
    enum AssetCodes: String {
        case bsv
        case btc
        case bch
        case eth
        case xrp
        
        var value: String { return rawValue }
    }
    
    var currencies = [CurrencyMetaData]()
    
    static let defaultCurrencyCodes = [AssetCodes.bsv.value,
                                       AssetCodes.btc.value,
                                       AssetCodes.eth.value]
    
    var defaultCurrencyIds: [CurrencyId] {
        return Currencies.defaultCurrencyCodes.compactMap { getUID(from: $0) }
    }
    
    init() {
        CurrencyFileManager.getCurrencyMetaDataFromCache { currency in
            let metaDatas = currency.values.compactMap { $0 } as? [CurrencyMetaData]
            self.currencies.removeAll()
            self.currencies.append(contentsOf: metaDatas ?? [])
        }
    }
    
    func getUID(from code: String) -> CurrencyId? {
        return currencies.first(where: { $0.code == code })?.uid
    }
}

struct CurrencyFileManager {
    static var sharedCurrenciesFilePath: String? = AppGroup.fabriikOne.containerURL?.appendingPathComponent("currencies.json").path
    static var bundledCurrenciesFilePath: String? = Bundle.main.path(forResource: "currencies", ofType: "json")
    static var cachedCurrenciesFilePath: String? {
        guard let sharedFilePath = sharedCurrenciesFilePath,
              let bundleFilePath = bundledCurrenciesFilePath else { return nil }
        
        if FileManager.default.fileExists(atPath: sharedFilePath) {
            return sharedFilePath
        } else {
            return bundleFilePath
        }
    }
    
    static func getCurrencyMetaDataFromCache(completion: @escaping ([CurrencyId: CurrencyMetaData]) -> Void) {
        guard let sharedFilePath = CurrencyFileManager.cachedCurrenciesFilePath else { return }
        
        _ = processCurrenciesCache(path: sharedFilePath, completion: completion)
    }
    
    // Converts an array of CurrencyMetaData to a dictionary keyed on uid
    static func processCurrencies(_ currencies: [CurrencyMetaData], completion: ([CurrencyId: CurrencyMetaData]) -> Void) {
        let currencyMetaData = currencies.reduce(into: [CurrencyId: CurrencyMetaData](), { (dict, token) in
            dict[token.uid] = token
        })
        
        print("[CurrencyList] tokens updated: \(currencies.count) tokens")
        
        completion(currencyMetaData)
    }

    // Loads and processes cached currencies
    static func processCurrenciesCache(path: String, completion: ([CurrencyId: CurrencyMetaData]) -> Void) -> Bool {
        guard FileManager.default.fileExists(atPath: path) else { return false }
        do {
            print("[CurrencyList] using cached token list")
            let cachedData = try Data(contentsOf: URL(fileURLWithPath: path))
            let currencies = try JSONDecoder().decode([CurrencyMetaData].self, from: cachedData)
            processCurrencies(currencies, completion: completion)
            return true
        } catch let e {
            print("[CurrencyList] error reading from cache: \(e)")
            // remove the invalid cached data
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            return false
        }
    }

    // Copies currencies embedded in bundle if cached file doesn't exist
    static func copyEmbeddedCurrencies(path: String) {
        let fileManager = FileManager.default
        
        if let embeddedFilePath = Bundle.main.path(forResource: "currencies", ofType: "json"), !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.copyItem(atPath: embeddedFilePath, toPath: path)
                print("[CurrencyList] copied bundle tokens list to cache")
            } catch let e {
                print("[CurrencyList] unable to copy bundled \(embeddedFilePath) -> \(path): \(e)")
            }
        }
    }
}
