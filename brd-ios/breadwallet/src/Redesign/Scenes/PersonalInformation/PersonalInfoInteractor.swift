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
        presenter?.presentData(actionResponse: .init(item: Models.Item(firstName: "Rok",
                                                                       lastName: "Cresnik",
                                                                       country: "Somewhere over the rainbow",
                                                                       birthdate: Date())))
    }

    // MARK: - Aditional helpers
}
