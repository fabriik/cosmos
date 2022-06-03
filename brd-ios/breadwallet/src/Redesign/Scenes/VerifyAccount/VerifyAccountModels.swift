//
// Created by Equaleyes Solutions Ltd
//

import UIKit
import SwiftUI

enum VerifyAccountModels {
    
    enum Section: Sectionable {
        case image
        case title
        case description
        case verifyButton
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
}
