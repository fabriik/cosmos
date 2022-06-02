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
                VerificationViewModel(title: .text("Level 1"),
                                      status: item.verificationStatus ?? .verified,
                                      description: .text("Personal information"),
                                      bottomButton: .init(title: "Account limit: $1,000/day ($10,000 lifetime)", image: nil)),
                VerificationViewModel(title: .text("Level 2"),
                                      status: item.verificationStatus ?? .pending,
                                      description: .text("ID Verification"),
                                      bottomButton: .init(title: "Account limit: Unlimited"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
