//
//  PersonalInfoVIP.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

extension Scenes {
    static let PersonalInfo = PersonalInfoViewController.self
}

protocol PersonalInfoViewActions: BaseViewActions, FetchViewActions {
    func countrySelected(viewAction: PersonalInfoModels.Country.ViewAction)
    func birthDateSet(viewAction: PersonalInfoModels.BirthDate.ViewAction)
    func nameSet(viewAction: PersonalInfoModels.Name.ViewAction)
    func validate(viewAction: PersonalInfoModels.Validate.ViewAction)
    func submit(vieAction: PersonalInfoModels.Submit.ViewAction)
}

protocol PersonalInfoActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: PersonalInfoModels.Validate.ActionResponse)
    func presentSubmit(actionResponse: PersonalInfoModels.Submit.ActionResponse)
}

protocol PersonalInfoResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: PersonalInfoModels.Validate.ResponseDisplay)
    func displaySubmit(responseDisplay: PersonalInfoModels.Submit.ResponseDisplay)
}

protocol PersonalInfoDataStore: BaseDataStore, FetchDataStore {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var country: String? { get set }
    var birthdate: Date? { get set }
}

protocol PersonalInfoDataPassing {
    var dataStore: PersonalInfoDataStore? { get }
}

protocol PersonalInfoRoutes: CoordinatableRoutes {
    func showCountrySelector(selected: ((String?) -> Void)?)
}
