// 
//  ErrorRequest.swift
//  breadwallet
//
//  Created by Rok on 29/04/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

extension BRAPIClient {
    // Sends logs to the BE
    func sendErrors(messages: [ErrorStruct], completion: @escaping (Bool) -> Void) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messages.data, options: .prettyPrinted)
        else { return }

        var req = URLRequest(url: url("/error"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonData
        
        dataTaskWithRequest(req, authenticated: true) { data, resp, err in
            guard err == nil,
                  data != nil,
                  resp?.statusCode == 200
            else {
                return completion(false)
            }
            print("success")
            completion(true)
        }.resume()
    }
}
