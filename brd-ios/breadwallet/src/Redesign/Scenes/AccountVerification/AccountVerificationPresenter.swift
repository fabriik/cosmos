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
            .title,
            .verificationLevel
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .title: [
                
            ],
            // TODO: localize!
            .verificationLevel: [
                VerificationViewModel(title: .text("Level 1"),
                                      status: .verified,
                                      description: .text("Personal information"),
                                      bottomButton: .init(title: "Account limit: Unlimited", image: nil)),
                VerificationViewModel(title: .text("Level 1"),
                                      status: .pending,
                                      description: .text("Personal information"),
                                      bottomButton: .init(title: "Higher swap limits")),
               
                VerificationViewModel(title: .text("Level 2"),
                                      status: .resubmit,
                                      description: .text("ID Verification"),
                                      bottomButton: .init(title: "Account limit: Unlimited"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
