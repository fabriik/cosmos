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
        
        let levelOneStatus: VerificationStatus
        let levelTwoStatus: VerificationStatus
        let description = item.failureReason ?? "ID Verification"
        
        if item.status.value.contains("KYC2") {
            levelOneStatus = .levelOne
            levelTwoStatus = item.status
        } else {
            levelOneStatus = item.status
            levelTwoStatus = .none
        }
        let isActive = levelOneStatus == .levelOne || item.status == .levelOne
        let sections = [ Models.Section.verificationLevel ]
        let sectionRows: [Models.Section: [Any]] = [
            .verificationLevel: [
                VerificationViewModel(kyc: .levelOne,
                                      title: .text("Level 1"),
                                      status: levelOneStatus,
                                      description: .text("Personal information"),
                                      benefits: .text("Account limit: $1,000/day ($10,000 lifetime)"),
                                      isActive: true),
                VerificationViewModel(kyc: .levelTwo,
                                      title: .text("Level 2"),
                                      status: levelTwoStatus,
                                      description: .text(description),
                                      benefits: .text("Swap limit: $10,000 per Swap, no lifetime limit"),
                                      isActive: isActive)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentStartVerification(actionResponse: AccountVerificationModels.Start.ActionResponse) {
        viewController?.displayStartVerification(responseDisplay: .init(level: actionResponse.level))
    }
    
    func presentPersonalInfoPopup(actionResponse: AccountVerificationModels.PersonalInfo.ActionResponse) {
        // TODO: localize
        let text = "We need to verify your personal information for compliance purposes. This information won’t be shared with outside sources unless required by law."
        let model = PopupViewModel(title: .text("Personal information"),
                                   body: text)
        
        viewController?.displayPersonalInfoPopup(responseDisplay: .init(model: model))
    }

    // MARK: - Additional Helpers

}
