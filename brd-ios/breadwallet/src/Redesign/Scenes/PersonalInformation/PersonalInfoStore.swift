//
//  PersonalInfoStore.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class PersonalInfoStore: NSObject, BaseDataStore, PersonalInfoDataStore {
    // MARK: - PersonalInfoDataStore
    // user id or smth?
    var itemId: String?
    var firstName: String?
    var lastName: String?
    var country: String?
    var birthdate: Date?
    
    var isValid: Bool {
        guard firstName?.isEmpty == false else { return false }
        guard lastName?.isEmpty == false else { return false }
        guard country?.isEmpty == false else { return false }
        guard birthdate != nil else { return false }
        return true
    }

    // MARK: - Aditional helpers
}
