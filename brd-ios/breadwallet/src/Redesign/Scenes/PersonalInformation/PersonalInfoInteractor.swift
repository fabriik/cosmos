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
        presenter?.presentData(actionResponse: .init(item: Models.Item(firstName: nil,
                                                                       lastName: nil,
                                                                       country: nil,
                                                                       birthdate: nil)))
    }

    // MARK: - Aditional helpers
}
