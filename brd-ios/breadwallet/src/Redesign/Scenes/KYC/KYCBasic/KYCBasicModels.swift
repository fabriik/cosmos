//
//  KYCBasicModels.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

enum KYCBasicModels {
    
    typealias Item = KYCBasicStore
 
    enum Section: Sectionable {
        case name
        case country
        case birthdate
        case confirm
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
    
    struct Name {
        struct ViewAction {
            var first: String?
            var last: String?
        }
    }
    
    struct Country {
        struct ViewAction {
            var code: String?
        }
    }
    
    struct BirthDate {
        struct ViewAction {
            var date: Date?
        }
    }
    
    struct Validate {
        struct ViewAction {}
        
        struct ActionResponse {
            var item: Item?
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct Submit {
        struct ViewAction {}
        
        struct ActionResponse {
            var error: Error?
        }
        
        struct ResponseDisplay {
            // TODO: should be replaced with error VM
            var error: Error?
        }
    }
}
