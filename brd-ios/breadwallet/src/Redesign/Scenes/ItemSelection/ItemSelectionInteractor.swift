//
//  ItemSelectionInteractor.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionInteractor: NSObject, Interactor, ItemSelectionViewActions {
    typealias Models = ItemSelectionModels

    var presenter: ItemSelectionPresenter?
    var dataStore: ItemSelectionStore?

    // MARK: - ItemSelectionViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let countries = dataStore?.countries else { return }
        
        let data = CountriesRequestData()
        
        CountriesWorker().execute(requestData: data) { [weak self] data, error in
            
        }
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(countries)))
    }
    
    func search(viewAction: ItemSelectionModels.Search.ViewAction) {
        guard let countries = dataStore?.countries else { return }
        
        let searchCountries = countries.filter { $0.contains(viewAction.text?.localizedUppercase ?? "") }
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(searchCountries)))
    }
    // MARK: - Aditional helpers
}
