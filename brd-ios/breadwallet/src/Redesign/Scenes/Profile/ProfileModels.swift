//
//  ProfileModels.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

enum ProfileModels {
    
    typealias Item = (title: String, image: String)
    
    enum Section: Sectionable {
        case profile
        case verification
        case navigation
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct ChangeAvatar {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
    
    struct VerificationInfo {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
}
