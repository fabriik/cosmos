//
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum AccountVerificationModels {
    
    typealias Item = AccountVerificationStore
    
    enum Section: Sectionable {
        case verificationLevel
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
