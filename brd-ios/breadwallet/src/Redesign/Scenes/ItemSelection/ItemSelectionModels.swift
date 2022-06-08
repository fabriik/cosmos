//
//  ItemSelectionModels.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

enum ItemSelectionModels {

    typealias Item = [CountryResponseData]
    enum Sections: Sectionable {
        case items
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
    
    enum Search {
        struct ViewAction {
            let text: String?
        }
    }
}
