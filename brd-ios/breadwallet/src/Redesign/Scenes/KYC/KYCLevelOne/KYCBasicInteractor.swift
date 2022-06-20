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
        dataStore?.firstName = viewAction.first
        dataStore?.lastName = viewAction.last
        
        validate(viewAction: .init())
    }
    
    func countrySelected(viewAction: KYCBasicModels.Country.ViewAction) {
        dataStore?.country = viewAction.code
        dataStore?.countryFullName = viewAction.fullName
        getData(viewAction: .init())
    }
    
    func birthDateSet(viewAction: KYCBasicModels.BirthDate.ViewAction) {
        dataStore?.birthdate = viewAction.date
        validate(viewAction: .init())
    }
    
    func validate(viewAction: KYCBasicModels.Validate.ViewAction) {
        presenter?.presentValidate(actionResponse: .init(item: dataStore))
    }
    
    func submit(vieAction: KYCBasicModels.Submit.ViewAction) {
        guard let firstName = dataStore?.firstName,
              let lastName = dataStore?.lastName,
              let country = dataStore?.country,
              let birthDateText = dataStore?.birthDateString,
              let birthDate = dataStore?.birthdate else {
            // should not happen
            return
        }
        
        guard let legalDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()),
            birthDate <= legalDate else {
            presenter?.presentNotification(actionResponse: .init(body: "You need to be at least 18 years old to complete Level 1 verification"))
            return
        }
        let data = KYCBasicRequestData(firstName: firstName,
                                       lastName: lastName,
                                       country: country,
                                       birthDate: birthDateText)
        
        KYCLevelOneWorker().execute(requestData: data) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            
            self?.presenter?.presentSubmit(actionResponse: .init())
        }
    }

    // MARK: - Aditional helpers
}
