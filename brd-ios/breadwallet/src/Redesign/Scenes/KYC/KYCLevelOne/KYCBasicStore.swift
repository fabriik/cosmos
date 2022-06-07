//
//  KYCBasicStore.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicStore: NSObject, BaseDataStore, KYCBasicDataStore {
    // MARK: - KYCBasicDataStore
    // user id or smth?
    var itemId: String?
    var firstName: String?
    var lastName: String?
    var country: String?
    var birthdate: Date?
    
    var birthDateString: String? {
        guard let birthdate = birthdate else { return nil }

        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: birthdate)
    }
    
    var isValid: Bool {
        guard firstName?.isEmpty == false else { return false }
        guard lastName?.isEmpty == false else { return false }
        guard country?.isEmpty == false else { return false }
        guard birthdate != nil else { return false }
        return true
    }

    // MARK: - Aditional helpers
}
