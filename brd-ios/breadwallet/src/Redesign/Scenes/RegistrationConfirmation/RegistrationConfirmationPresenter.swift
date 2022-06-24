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
        var help: [ButtonViewModel] = [ButtonViewModel(title: "Re-send my code", isUnderlined: true)]
        
        if UserManager.shared.profile?.status == .emailPending
            || UserManager.shared.profile?.status == nil {
            help.append(ButtonViewModel(title: "Change my email", isUnderlined: true))
        }
        
        let sectionRows: [Models.Section: [Any]] = [
            .image: [
                ImageViewModel.imageName("email")
            ],
            .title: [
                LabelViewModel.text("Verify your email")
            ],
            .instructions: [
                LabelViewModel.text("Please enter the code we’ve sent to: \(email ?? "")")
            ],
            .input: [
                // TODO: validator?
                TextFieldModel(title: "Email", value: email)
            ],
            .confirm: [
                ButtonViewModel(title: "Confirm", enabled: false)
            ],
            .help: [
                ScrollableButtonsViewModel(buttons: help)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: RegistrationConfirmationModels.Validate.ActionResponse) {
        let code = actionResponse.item ?? ""
        guard code.count <= 6 else { return }
        
        viewController?.displayValidate(responseDisplay: .init(isValid: code.count == 6))
    }
    
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse) {
        // TODO: localize
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text("Verification code sent.")),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentError(actionResponse: RegistrationConfirmationModels.Error.ActionResponse) {
        viewController?.displayError(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers

}
