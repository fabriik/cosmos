// 
//  WyreRequest.swift
//  breadwallet
//
//  Created by Rok on 18/03/2022.
//  Copyright © 2022 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct WyreRequest: ExternalAPIRequest {
    typealias Response = String
    var hostName = "https://pay.testwyre.com"
    var resourceName = "purchase"
    private static var wyreToken = "SK-DH6XP4AX-ZQ3ULQ2G-6CVP3PF9-TFJ4N7VJ"
    
    let headers = [
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer \(WyreRequest.wyreToken)"
    ]
    
    func generateRequest() -> URLRequest? {
        guard let url = URL(string: hostName) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.name
        request.allHTTPHeaderFields = headers
        return request
    }
}
