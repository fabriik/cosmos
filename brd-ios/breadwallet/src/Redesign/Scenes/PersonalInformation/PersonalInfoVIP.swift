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
}

protocol PersonalInfoActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol PersonalInfoResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
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
    func showCountrySelector(selected: ((String) -> Void)?)
}
