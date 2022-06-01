//
// Created by Equaleyes Solutions Ltd
//

import UIKit

final class AccountVerificationPresenter: NSObject, Presenter, AccountVerificationActionResponses {
    
    typealias Models = AccountVerificationModels

    weak var viewController: AccountVerificationViewController?

    // MARK: - AccountVerificationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        
        let sections: [Models.Section] = [
            .verificationLevel
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            // TODO: localize!
            .verificationLevel: [
                VerificationViewModel(title: .text("Level 1"),
                                      status: .verified,
                                      description: .text("Personal information"),
                                      bottomButton: .init(title: "Account limit: $1,000/day ($10,000 lifetime)", image: nil)),
                VerificationViewModel(title: .text("Level 2"),
                                      status: .pending,
                                      description: .text("ID Verification"),
                                      bottomButton: .init(title: "Account limit: Unlimited"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
