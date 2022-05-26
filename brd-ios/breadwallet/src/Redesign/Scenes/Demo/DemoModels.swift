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
        case navigation
        case label
        case button
        case textField
        case infoView
        
        var header: AccessoryType? {
            return nil
            switch self {
            case .profile:
                return .plain("Profile")
            case .navigation:
                return .plain("Navigation")
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
        
        var footer: AccessoryType? {
            return nil
            return .plain("End of section")
        }
    }
    
}
