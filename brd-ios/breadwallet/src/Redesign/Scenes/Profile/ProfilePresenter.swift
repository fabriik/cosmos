//
//  ProfilePresenter.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

final class ProfilePresenter: NSObject, Presenter, ProfileActionResponses {
    
    typealias Models = ProfileModels

    weak var viewController: ProfileViewController?

    // MARK: - ProfileActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [
            .profile,
            .verification,
            .navigation
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .profile: [
                ProfileViewModel(name: item.title, image: item.image)
            ],
            // TODO: localize!
            .verification: [
                InfoViewModel(headerTitle: .text("ACCOUNT VERIFICATION"),
                              headerTrailingImage: .imageName("infoIcon"),
                              description: .text("Upgrade your limits and get full access!"),
                              button: .init(title: "Verify your account"))
            ],
            .navigation: [
                NavigationViewModel(image: .imageName("lock_closed"),
                                label: .text("Security settings"),
                                button: .init(image: "arrow_right")),
                NavigationViewModel(image: .imageName("settings"),
                                label: .text("Preferences"),
                                button: .init(image: "arrow_right")),
                NavigationViewModel(image: .imageName("withdrawal"),
                                label: .text("Export transaction history to csv"),
                                button: .init(image: "arrow_right"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    // MARK: - Additional Helpers

}
