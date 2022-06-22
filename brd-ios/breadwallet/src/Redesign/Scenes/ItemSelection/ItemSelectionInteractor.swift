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
        CountriesWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.countries = data
                self?.presenter?.presentData(actionResponse: .init(item: data))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func search(viewAction: ItemSelectionModels.Search.ViewAction) {
        guard let countries = dataStore?.countries,
              let searchText = viewAction.text?.lowercased() else { return }
        
        let searchData = searchText.isEmpty ? countries : countries.filter { $0.localizedName?.lowercased().contains(searchText) as? Bool ?? false }
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(searchData)))
    }
    // MARK: - Aditional helpers
}
