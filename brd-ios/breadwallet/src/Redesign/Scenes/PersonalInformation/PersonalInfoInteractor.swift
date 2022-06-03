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
        validate(viewAction: .init())
    }
    
    func nameSet(viewAction: PersonalInfoModels.Name.ViewAction) {
        if let value = viewAction.first {
            dataStore?.firstName = value
        }
        if let value = viewAction.last {
            dataStore?.lastName = value
        }
        validate(viewAction: .init())
    }
    
    func countrySelected(viewAction: PersonalInfoModels.Country.ViewAction) {
        guard  let country = viewAction.code else { return }
        dataStore?.country = country
        getData(viewAction: .init())
    }
    
    func birthDateSet(viewAction: PersonalInfoModels.BirthDate.ViewAction) {
        guard  let date = viewAction.date else { return }
        dataStore?.birthdate = date
        validate(viewAction: .init())
    }
    
    func validate(viewAction: PersonalInfoModels.Validate.ViewAction) {
        presenter?.presentValidate(actionResponse: .init(item: dataStore))
    }
    
    func submit(vieAction: PersonalInfoModels.Submit.ViewAction) {
        guard let firstName = dataStore?.firstName,
              let lastName = dataStore?.lastName,
              let country = dataStore?.country,
              let birthDate = dataStore?.birthdate else {
            // should not happen
            return
        }
        let data = PersonalInfoRequestData(firstName: firstName,
                                           lastName: lastName,
                                           country: country,
                                           birthDate: birthDate)
        
        PersonalInfoWorker().execute(requestData: data) { [weak self] error in
            self?.presenter?.presentSubmit(actionResponse: .init(error: error))
        }
    }

    // MARK: - Aditional helpers
}

struct PersonalInfoRequestData: RequestModelData {
    var firstName: String
    var lastName: String
    var country: String
    var birthDate: String
    
    func getParameters() -> [String : Any] {
        return [
            "first_name": firstName,
            "last_name": lastName,
            "country": country,
            "date_of_birth": birthDate
        ]
    }
}

class PersonalInfoWorker: BasePlainResponseWorker {
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.basic)
    }
}
