//
//  ItemSelectionVIP.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

extension Scenes {
    static let ItemSelection = ItemSelectionViewController.self
}

protocol ItemSelectionViewActions: BaseViewActions, FetchViewActions {
}

protocol ItemSelectionActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol ItemSelectionResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol ItemSelectionDataStore: BaseDataStore, FetchDataStore {
}

protocol ItemSelectionDataPassing {
    var dataStore: ItemSelectionDataStore? { get }
}

protocol ItemSelectionRoutes: CoordinatableRoutes {
}
