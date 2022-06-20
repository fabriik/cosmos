//
//  ProfilePresenter.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

extension ProfileModels.NavigationItems {
    
    var model: NavigationViewModel {
        switch self {
        case .security:
            return .init(image: .imageName("lock_closed"),
                         label: .text("Security settings"),
                         button: .init(image: "arrow_right"))
            
        case .preferences:
            return .init(image: .imageName("settings"),
                         label: .text("Preferences"),
                         button: .init(image: "arrow_right"))
        }
    }
}

final class ProfilePresenter: NSObject, Presenter, ProfileActionResponses {
    
    typealias Models = ProfileModels

    weak var viewController: ProfileViewController?

    // MARK: - ProfileActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let status = item.status
        var infoView: InfoViewModel
        switch status {
        case .none:
            infoView = Presets.VerificationInfoView.none
        case .emailPending, .levelTwo(.submitted):
            infoView = Presets.VerificationInfoView.pending
        case .email, .levelOne, .levelTwo(.notStarted):
            infoView = Presets.VerificationInfoView.verified
        case .levelTwo(.levelTwo):
            infoView = Presets.VerificationInfoView.verifiedLevelTwo
        case .levelTwo(.expired), .levelTwo(.resubmit):
            infoView = Presets.VerificationInfoView.resubmit
        case .levelTwo(.declined):
            infoView = Presets.VerificationInfoView.declined
        }
        
        let sections: [Models.Section] = [
            .profile,
            .verification,
            .navigation
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .profile: [
                ProfileViewModel(name: item.title ?? "<unknown", image: item.image)
            ],
            .verification: [
                infoView
            ],
            .navigation: Models.NavigationItems.allCases.compactMap { $0.model }
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse) {
        // TODO: localize
        let text = """
If you verify your account, you are given acces to:
  - Unlimited deposits/withdraws
  - Enhanced security
  - Full asset support
  - Buy crypto with card
  - 24/7/365 live customer support
"""
        let model = PopupViewModel(title: .text("Why should I verify my account?"),
                                   body: text)
        
        viewController?.displayVerificationInfo(responseDisplay: .init(model: model))
    }
    
    func presentNavigation(actionResponse: ProfileModels.Navigate.ActionResponse) {
        let item = Models.NavigationItems.allCases[actionResponse.index]
        viewController?.displayNavigation(responseDisplay: .init(item: item))
    }
    // MARK: - Additional Helpers

}
