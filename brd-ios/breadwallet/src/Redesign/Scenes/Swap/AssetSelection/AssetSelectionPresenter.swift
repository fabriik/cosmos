//
//  AssetSelectionPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 6.7.22.
//
//

import UIKit

final class AssetSelectionPresenter: NSObject, Presenter, AssetSelectionActionResponses {
    typealias Models = AssetSelectionModels

    weak var viewController: AssetSelectionViewController?

    // MARK: - AssetSelectionActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let image = TokenImageSquareBackground(code: "BTC", color: .red).renderedImage ?? UIImage()
        
        let sections = [Models.Sections.items]
        let sectionRows = [
            Models.Sections.items: [
                AssetViewModel(icon: .image(image), title: "Bitcoin", subtitle: "BTC", topRightText: "3 BTC", bottomRightText: "$2.523"),
                AssetViewModel(icon: .image(image), title: "Ethereum", subtitle: "ETH", topRightText: "0.5612 ETH", bottomRightText: "$220.52")
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
