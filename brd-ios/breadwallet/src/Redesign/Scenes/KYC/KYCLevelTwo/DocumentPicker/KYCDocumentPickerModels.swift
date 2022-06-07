//
//  KYCDocumentPickerModels.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

enum KYCDocumentPickerModels {
    typealias Item = [Document]
    
    enum Sections: Sectionable {
        case title
        case documents
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Documents {
        struct ViewAction {
            var index: Int?
        }
        
        struct ActionResponse {
            var document: Document?
        }
        
        struct ResponseDisplay {
            var document: Document
        }
    }
}
