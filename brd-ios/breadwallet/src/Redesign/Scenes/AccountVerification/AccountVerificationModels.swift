//
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum AccountVerificationModels {
    
    typealias Item = (title: String, image: String)
    
    enum Section: Sectionable {
        case title
        case verificationLevel
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum LevelItems: String, CaseIterable {
        case level1
        case level2
    }
}
