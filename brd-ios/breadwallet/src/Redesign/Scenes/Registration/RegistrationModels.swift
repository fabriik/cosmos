//
//  RegistrationModels.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

enum RegistrationModels {
    
    enum ViewType {
        case registration
        case resend
        
        var title: String {
            switch self {
            case .registration:
                return "Welcome!"
                
            case .resend:
                return "Change your email"
            }
        }
        
        var instructions: String {
            switch self {
            case .registration:
                return "Create a Fabriik account by entering your email address."
                
            case .resend:
                return "Enter and verify your new email address for your Fabriik account."
            }
        }
    }
    
    typealias Item = (email: String?, type: ViewType?)
    
    enum Section: Sectionable {
        case image
        case title
        case instructions
        case email
        case confirm
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var item: String?
        }
        
        struct ActionResponse {
            var item: String?
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {
            var email: String?
        }
        struct ResponseDisplay {
            var email: String?}
    }
}
