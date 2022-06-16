//
//  RegistrationConfirmationPresenter.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

final class RegistrationConfirmationPresenter: NSObject, Presenter, RegistrationConfirmationActionResponses {
    typealias Models = RegistrationConfirmationModels

    weak var viewController: RegistrationConfirmationViewController?

    // MARK: - RegistrationConfirmationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let email = actionResponse.item as? String
        let sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .input,
            .confirm,
            .help
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .image: [
                ImageViewModel.imageName("email")
            ],
            .title: [
                LabelViewModel.text("Verify your email")
            ],
            .instructions: [
                LabelViewModel.text("Please enter the code we’ve sent to: \(email ?? "missing")")
            ],
            .input: [
                // TODO: validator?
                TextFieldModel(title: "Email", value: email)
            ],
            .confirm: [
                ButtonViewModel(title: "Confirm", enabled: false)
            ],
            .help: [
                ScrollableButtonsViewModel(buttons: [
                    ButtonViewModel(title: "Re-send my code", isUnderlined: true),
                    ButtonViewModel(title: "Change my email", isUnderlined: true)
                ])
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: RegistrationConfirmationModels.Validate.ActionResponse) {
        let code = actionResponse.item ?? ""
        viewController?.displayValidate(responseDisplay: .init(isValid: code.count == 6))
    }
    
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse) {
        // TODO: localize
        viewController?.displayNotification(responseDisplay: .init(model: .init(description: .text("Verification code sent.")), config: Presets.InfoView.verification))
    }
    // MARK: - Additional Helpers

}
