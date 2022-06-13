//
//  ItemSelectionPresenter.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

final class ItemSelectionPresenter: NSObject, Presenter, ItemSelectionActionResponses {
    typealias Models = ItemSelectionModels

    weak var viewController: ItemSelectionViewController?

    // MARK: - ItemSelectionActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections = [Models.Sections.items]
        let sectionRows = [
            Models.Sections.items: item
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    // MARK: - Additional Helpers

}
