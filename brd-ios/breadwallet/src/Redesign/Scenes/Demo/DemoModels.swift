//
//  DemoModels.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit

enum DemoModels {
    
    enum Section: Sectionable {
        case profile
        case verification
        case navigation
        case label
        case button
        case textField
        case infoView
        case name
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
}
