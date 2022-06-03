//
//  RegistrationPresenter.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

final class RegistrationPresenter: NSObject, Presenter, RegistrationActionResponses {
    typealias Models = RegistrationModels

    weak var viewController: RegistrationViewController?

    // MARK: - RegistrationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .email,
            .confirm
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .image: [
                ImageViewModel.imageName("registration")
            ],
            .title: [
                LabelViewModel.text(item.type?.title)
            ],
            .instructions: [
                LabelViewModel.text(item.type?.instructions)
            ],
            .email: [
                // TODO: validator?
                TextFieldModel(title: "Email", value: item.email)
            ],
            .confirm: [
                ButtonViewModel(title: "Next", enabled: false)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: RegistrationModels.Validate.ActionResponse) {
        let item = actionResponse.item ?? ""
        viewController?.displayValidate(responseDisplay: .init(isValid: item.isValidEmailAddress))
    }
    
    func presentNext(actionResponse: RegistrationModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    // MARK: - Additional Helpers
}
