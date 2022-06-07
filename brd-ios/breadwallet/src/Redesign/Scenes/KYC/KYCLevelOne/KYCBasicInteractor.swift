//
//  KYCBasicInteractor.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicInteractor: NSObject, Interactor, KYCBasicViewActions {
    typealias Models = KYCBasicModels

    var presenter: KYCBasicPresenter?
    var dataStore: KYCBasicStore?

    // MARK: - KYCBasicViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore))
        validate(viewAction: .init())
    }
    
    func nameSet(viewAction: KYCBasicModels.Name.ViewAction) {
        if let value = viewAction.first {
            dataStore?.firstName = value
        }
        if let value = viewAction.last {
            dataStore?.lastName = value
        }
        validate(viewAction: .init())
    }
    
    func countrySelected(viewAction: KYCBasicModels.Country.ViewAction) {
        guard  let country = viewAction.code else { return }
        dataStore?.country = country
        getData(viewAction: .init())
    }
    
    func birthDateSet(viewAction: KYCBasicModels.BirthDate.ViewAction) {
        guard  let date = viewAction.date else { return }
        dataStore?.birthdate = date
        validate(viewAction: .init())
    }
    
    func validate(viewAction: KYCBasicModels.Validate.ViewAction) {
        presenter?.presentValidate(actionResponse: .init(item: dataStore))
    }
    
    func submit(vieAction: KYCBasicModels.Submit.ViewAction) {
        guard let firstName = dataStore?.firstName,
              let lastName = dataStore?.lastName,
              let country = dataStore?.country,
              let birthDate = dataStore?.birthDateString else {
            // should not happen
            return
        }
        let data = KYCBasicRequestData(firstName: firstName,
                                           lastName: lastName,
                                           country: country,
                                           birthDate: birthDate)
        
        KYCBasicWorker().execute(requestData: data) { [weak self] error in
            self?.presenter?.presentSubmit(actionResponse: .init(error: error))
        }
    }

    // MARK: - Aditional helpers
}

struct KYCBasicRequestData: RequestModelData {
    var firstName: String
    var lastName: String
    var country: String
    var birthDate: String
    
    func getParameters() -> [String: Any] {
        return [
            "first_name": firstName,
            "last_name": lastName,
            "country": country,
            "date_of_birth": birthDate
        ]
    }
}

class KYCBasicWorker: BasePlainResponseWorker {
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.basic)
    }
    
    override func getMethod() -> EQHTTPMethod {
        return .post
    }
}
