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

class SharedCurrency: CurrencyUID {
    public enum TokenType: String {
        case native
        case erc20
        case unknown
    }
    
    /// Unique identifier from BlockchainDB
    var uid: CurrencyId { return .init(rawValue: "") }
    
    /// Display name (e.g. Bitcoin)
    var name: String { return ""}
    
    var tokenType: TokenType { return .unknown }
    
    var coinGeckoId: String? { return "" }
    
    /// Primary + secondary color
    var colors: (UIColor, UIColor) { return (.clear, .clear) }
    
    var code: String { return "" }
    
    /// False if a token has been delisted, true otherwise
    var isSupported: Bool { return false }
    
    var isBitcoin: Bool { return uid == Currencies.btc.uid }
    var isBitcoinSV: Bool { return uid == Currencies.bsv.uid }
    var isBitcoinCash: Bool { return uid == Currencies.bch.uid }
    var isEthereum: Bool { return uid == Currencies.eth.uid }
    var isERC20Token: Bool { return tokenType == .erc20 }
    var isBRDToken: Bool { return uid == Currencies.brd.uid }
    var isXRP: Bool { return uid == Currencies.xrp.uid }
    var isHBAR: Bool { return uid == Currencies.hbar.uid }
    var isBitcoinCompatible: Bool { return isBitcoin || isBitcoinCash }
    var isEthereumCompatible: Bool { return isEthereum || isERC20Token }
    var isTezos: Bool { return uid == Currencies.xtz.uid }
    
    init() {}
}
