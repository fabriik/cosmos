//
//  AssetSelectionModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 6.7.22.
//
//

import UIKit

enum AssetSelectionModels {
    typealias Item = ()
    
    enum Sections: Sectionable {
        case items
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
}
