// 
//  KYCDocumentWorker.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum Document: String, Model {
    case passport
    case idCard
    case driversLicense
    case residencePermit
    
    init(from rawValue: String?) {
        switch rawValue {
        case "ID_CARD":
            self = .idCard
            
        case "DRIVERS_LICENSE":
            self = .driversLicense
            
        case "RESIDENCE_PERMIT":
            self = .residencePermit
            
        default:
            self = .passport
        }
    }
    
    var imageName: String {
        switch self {
        case .passport:
            return "passport"
            
        case .idCard:
            return "idCard"
            
        case .driversLicense:
            return "driversLicense"
            
        case .residencePermit:
            return "residencePermit"
        }
    }
    
    var title: String {
        switch self {
        case .passport: return "Passport"
        case .idCard: return "National ID card"
        case .driversLicense: return "Driver’s license"
        case .residencePermit: return "Residence permit"
        }
    }
}

struct KYCDocumentResponseData: ModelResponse {
    var supportedDocuments: [String]
}
    
class KYCDocumentMapper: ModelMapper<KYCDocumentResponseData, [Document]> {
    override func getModel(from response: KYCDocumentResponseData) -> [Document]? {
        return response.supportedDocuments.compactMap { return Document(from: $0) }
    }
}

class KYCDocumentWorker: BaseResponseWorker<KYCDocumentResponseData,
                         [Document],
                         KYCDocumentMapper> {
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.documents)
    }
}