//
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum AccountVerificationModels {
    
    typealias Item = [Any]
    
    enum Section: Sectionable {
        case verificationLevel
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
