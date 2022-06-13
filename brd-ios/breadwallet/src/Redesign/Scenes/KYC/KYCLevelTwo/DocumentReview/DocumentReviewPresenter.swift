//
//  DocumentReviewPresenter.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//
//

import UIKit

final class DocumentReviewPresenter: NSObject, Presenter, DocumentReviewActionResponses {
    typealias Models = DocumentReviewModels
    
    weak var viewController: DocumentReviewViewController?
    
    // MARK: - DocumentReviewActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
        let image = item.image else { return }
        
        let sections: [Models.Sections] =  [
            .title,
            .checkmarks,
            .image,
            .buttons
        ]
        
        let sectionRows: [Models.Sections: [Any]] = [
            .title: [LabelViewModel.text("Before you confirm, please:")],
            .checkmarks: [
                ChecklistItemViewModel(title: .text("You have captured the entire front page of the document")),
                ChecklistItemViewModel(title: .text("Make sure document details are clearly visible and within the frame"))
            ],
            .image: [ImageViewModel.image(image)],
            .buttons: [
                ScrollableButtonsViewModel(buttons: [
                    .init(title: "Retake photo"),
                    .init(title: "Confirm")
                ])
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
