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
    
    enum NavigationItems: CaseIterable {
        case security
        case preferences
        case export
    }
    
    struct Navigate {
        struct ViewAction {
            var index: Int
        }
        struct ActionResponse {
            var index: Int
        }
        struct ResponseDisplay {
            var item: NavigationItems
        }
    }
    
    struct VerificationInfo {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
}
