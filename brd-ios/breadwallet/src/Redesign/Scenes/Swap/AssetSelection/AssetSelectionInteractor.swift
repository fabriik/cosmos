//
//  AssetSelectionInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 6.7.22.
//
//

import UIKit

class AssetSelectionInteractor: NSObject, Interactor, AssetSelectionViewActions {
    
    typealias Models = AssetSelectionModels

    var presenter: AssetSelectionPresenter?
    var dataStore: AssetSelectionStore?

    // MARK: - AssetSelectionViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item()))
    }

    // MARK: - Aditional helpers
}
