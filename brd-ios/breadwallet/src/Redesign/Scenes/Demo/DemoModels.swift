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
        case verification
        case label
        case button
        case textField
        case infoView
        
        var header: AccessoryType? {
            switch self {
            case .verification:
                return .plain("Verification")
            case .label:
                return .plain("Labels")
            case .button:
                return .plain("Buttons")
            case .textField:
                return .plain("Text fields")
            case .infoView:
                return .plain("Info view")
            }
            
        }
        
        var footer: AccessoryType? { return .plain("End of section") }
    }
    
}
