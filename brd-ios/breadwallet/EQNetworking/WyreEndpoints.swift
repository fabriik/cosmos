// 
//  WyreEndpoints.swift
//  breadwallet
//
//  Created by Rok on 29/03/2022.
//  Copyright © 2022 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum WyreEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/"
    
    case reserve = "wyre/reserve?%@&%@io, "
    
    var url: String {
        return Self.baseURL + rawValue
    }
}
