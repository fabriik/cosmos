//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AccountVerificationStore: NSObject, BaseDataStore, AccountVerificationDataStore {
    
    var itemId: String?
    var verified: VerificationStatus?
    var pending: VerificationStatus?
    var resubmit: VerificationStatus?
    
    // MARK: - AccountVerificationDataStore

    // MARK: - Aditional helpers
}
