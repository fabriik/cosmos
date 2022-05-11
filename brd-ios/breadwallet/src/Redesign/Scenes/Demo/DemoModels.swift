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
        
        var header: AccessoryType? { return .plain("rok") }
        var footer: AccessoryType? { return .action("CLICK") }
    }
    
}
