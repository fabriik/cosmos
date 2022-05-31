//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension AccountVerificationModels.LevelItems {
    
    var model: NavigationViewModel {
        switch self {
        case .level1:
            return .init(image: .imageName("lock_closed"),
                         label: .text("Security settings"),
                         button: .init(image: "arrow_right"))
            
        case .level2:
            return .init(image: .imageName("settings"),
                         label: .text("Preferences"),
                         button: .init(image: "arrow_right"))
        }
    }
}

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
                                      description: .text("ID Verification"),
                                      bottomButton: .init(title: "Account limit: Unlimited", image: nil)),
                VerificationViewModel(title: .text("Level 1"),
                                      status: .pending,
                                      description: .text("Personal information"),
                                      bottomButton: .init(title: "Verify your account")),
               
                VerificationViewModel(title: .text("Level 2"),
                                      status: .resubmit,
                                      infoButton: .init(image: "infoIcon"),
                                      description: .text("ID Verification"),
                                      bottomButton: .init(title: "Account limit: Unlimited", image: nil))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
