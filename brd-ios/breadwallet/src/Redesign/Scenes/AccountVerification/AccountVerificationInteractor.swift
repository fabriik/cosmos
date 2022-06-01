//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AccountVerificationInteractor: NSObject, Interactor, AccountVerificationViewActions {
    
    typealias Models = AccountVerificationModels

    var presenter: AccountVerificationPresenter?
    var dataStore: AccountVerificationStore?

    // MARK: - AccountVerificationViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let verificationItems = [
            VerificationViewModel(title: .text("Level 1"),
                                  status: .verified,
                                  description: .text("Personal information"),
                                  bottomButton: .init(title: "Account limit: $1,000/day ($10,000 lifetime)", image: nil)),
            VerificationViewModel(title: .text("Level 2"),
                                  status: .pending,
                                  description: .text("ID Verification"),
                                  bottomButton: .init(title: "Account limit: Unlimited"))
        ]
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(verificationItems)))
    }

    // MARK: - Aditional helpers
}
