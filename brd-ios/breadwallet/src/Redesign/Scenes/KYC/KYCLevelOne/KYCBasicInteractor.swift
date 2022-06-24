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
        ProfileWorker().execute { [weak self] result in
            switch result {
            case .success(let profileData):
                CountriesWorker().execute(requestData: CountriesRequestData()) { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.dataStore?.firstName = profileData.firstName
                        self?.dataStore?.lastName = profileData.lastName
                        self?.dataStore?.country = profileData.country
                        self?.dataStore?.countryFullName = data.first(where: { $0.iso2 == self?.dataStore?.country })?.localizedName
                        
                        self?.dataStore?.birthdate = self?.getBirthDateFormatter().date(from: profileData.dateOfBirth ?? "")
                        self?.dataStore?.birthDateString = self?.getBirthDateFormatter().string(from: self?.dataStore?.birthdate ?? Date())
                        
                        self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                        self?.validate(viewAction: .init())
                        
                    case .failure(let error):
                        self?.presenter?.presentError(actionResponse: .init(error: error))
                    }
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func nameSet(viewAction: KYCBasicModels.Name.ViewAction) {
        dataStore?.firstName = viewAction.first
        dataStore?.lastName = viewAction.last
        
        validate(viewAction: .init())
    }
    
    func countrySelected(viewAction: KYCBasicModels.Country.ViewAction) {
        dataStore?.country = viewAction.code
        dataStore?.countryFullName = viewAction.countryFullName
        
        presenter?.presentData(actionResponse: .init(item: dataStore))
        validate(viewAction: .init())
    }
    
    func birthDateSet(viewAction: KYCBasicModels.BirthDate.ViewAction) {
        dataStore?.birthdate = viewAction.date
        dataStore?.birthDateString = getBirthDateFormatter().string(from: dataStore?.birthdate ?? Date())
        
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
    
    func getBirthDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }
}
