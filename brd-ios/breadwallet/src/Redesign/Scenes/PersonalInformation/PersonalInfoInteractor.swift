//
//  PersonalInfoInteractor.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class PersonalInfoInteractor: NSObject, Interactor, PersonalInfoViewActions {
    typealias Models = PersonalInfoModels

    var presenter: PersonalInfoPresenter?
    var dataStore: PersonalInfoStore?

    // MARK: - PersonalInfoViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore))
        validate(viewACtion: .init())
    }
    
    func nameSet(viewAction: PersonalInfoModels.Name.ViewAction) {
        if let value = viewAction.first {
            dataStore?.firstName = value
        }
        if let value = viewAction.last {
            dataStore?.lastName = value
        }
        validate(viewACtion: .init())
    }
    
    func countrySelected(viewAction: PersonalInfoModels.Country.ViewAction) {
        guard  let country = viewAction.code else { return }
        dataStore?.country = country
        getData(viewAction: .init())
    }
    
    func birthDateSet(viewAction: PersonalInfoModels.BirthDate.ViewAction) {
        guard  let date = viewAction.date else { return }
        dataStore?.birthdate = date
        validate(viewACtion: .init())
    }
    
    func validate(viewACtion: PersonalInfoModels.Validate.ViewAction) {
        presenter?.presentValidate(actionResponse: .init(item: dataStore))
    }

    // MARK: - Aditional helpers
}
