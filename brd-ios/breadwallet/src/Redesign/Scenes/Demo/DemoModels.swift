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
        case demo
        case button
        case textField
        
        var header: AccessoryType? {
            switch self {
            case .demo:
                return .plain("Labels")
            case .button:
                return .plain("Buttons")
            case .textField:
                return .plain("Text fields")
            }
            
        }
        
        var footer: AccessoryType? { return .plain("End of section") }
    }
    
}
