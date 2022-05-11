//
//  ErrorModels.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import Foundation

enum ErrorModels {
    typealias ErrorConfiguration = Any
    
    enum Errors {
        struct ViewAction {
            init() {}
        }
        
        struct ActionResponse {
             let error: Error?

            init(error: Error?) {
                self.error = error
            }
        }
        
        struct ResponseDisplay {
            let config: ErrorConfiguration
            
            init(config: ErrorConfiguration) {
                self.config = config
            }
        }
    }
}
