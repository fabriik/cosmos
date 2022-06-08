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
        let data = CountriesRequestData()
        CountriesWorker().execute(requestData: data) { [weak self] countries, error in
            guard let countries = countries, error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            self?.dataStore?.countries = countries
            self?.presenter?.presentData(actionResponse: .init(item: countries))
        }
    }
    
    func search(viewAction: ItemSelectionModels.Search.ViewAction) {
        guard let countries = dataStore?.countries,
        let searchText = viewAction.text else { return }
        
        var searchData = searchText.isEmpty ? countries : countries.filter { $0.localizedName?.contains(searchText) as? Bool ?? false }
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(searchData)))
    }
    // MARK: - Aditional helpers
}
