//
//  RegistrationConfirmationVIP.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

extension Scenes {
    static let RegistrationConfirmation = RegistrationConfirmationViewController.self
}

protocol RegistrationConfirmationViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction)
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction)
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction)
}

protocol RegistrationConfirmationActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: RegistrationConfirmationModels.Validate.ActionResponse)
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse)
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse)
}

protocol RegistrationConfirmationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: RegistrationConfirmationModels.Validate.ResponseDisplay)
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay)
    func displayResend(responseDisplay: RegistrationConfirmationModels.Resend.ResponseDisplay)
}

protocol RegistrationConfirmationDataStore: BaseDataStore, FetchDataStore {
    var email: String? { get set }
}

protocol RegistrationConfirmationDataPassing {
    var dataStore: RegistrationConfirmationDataStore? { get }
}

protocol RegistrationConfirmationRoutes: CoordinatableRoutes {
}
