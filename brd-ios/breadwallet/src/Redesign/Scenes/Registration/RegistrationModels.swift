//
//  RegistrationModels.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

enum RegistrationModels {
    typealias Item = String?
    
    enum Section: Sectionable {
        case image
        case title
        case instructions
        case email
        case confirm
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var item: Item
        }
        
        struct ActionResponse {
            var item: Item
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
