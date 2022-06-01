//
//  PersonalInfoModels.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

enum PersonalInfoModels {
    
    typealias Item = (firstName: String?, lastName: String?, country: String?, birthdate: Date?)
 
    enum Section: Sectionable {
        case name
        case country
        case birthdate
        case confirm
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
    
    struct Country {
        struct ViewAction {
            var code: String?
        }
    }
}
