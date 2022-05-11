//
//  ErrorModels.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import Foundation

enum ErrorModels {
    enum Errors {
        struct ViewAction {}
        
        struct ActionResponse {
             let error: Error?
        }
        
        struct ResponseDisplay {
            let model: AlertViewModel?
            let config: AlertConfiguration?
        }
    }
}
