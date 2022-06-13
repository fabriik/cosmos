//
// Created by Equaleyes Solutions Ltd
//

import UIKit

final class AccountVerificationPresenter: NSObject, Presenter, AccountVerificationActionResponses {
    
    typealias Models = AccountVerificationModels

    weak var viewController: AccountVerificationViewController?

    // MARK: - AccountVerificationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections = [ Models.Section.verificationLevel ]
        let sectionRows: [Models.Section: [Any]] = [
            .verificationLevel: [
                VerificationViewModel(kyc: .levelOne,
                                      title: .text("Level 1"),
                                      status: item.status,
                                      description: .text("Personal information"),
                                      benefits: .text("Account limit: $1,000/day ($10,000 lifetime)")),
                VerificationViewModel(kyc: .levelTwo,
                                      title: .text("Level 2"),
                                      status: item.status,
                                      description: .text("ID Verification"),
                                      benefits: .text("Swap limit: $10,000 per Swap, no lifetime limit"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentStartVerification(actionResponse: AccountVerificationModels.Start.ActionResponse) {
        viewController?.displayStartVerification(responseDisplay: .init(level: actionResponse.level))
    }

    // MARK: - Additional Helpers

}
