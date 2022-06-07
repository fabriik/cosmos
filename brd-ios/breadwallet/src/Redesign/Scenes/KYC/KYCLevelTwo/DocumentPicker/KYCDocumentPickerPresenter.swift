//
//  KYCDocumentPickerPresenter.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

final class KYCDocumentPickerPresenter: NSObject, Presenter, KYCDocumentPickerActionResponses {
    typealias Models = KYCDocumentPickerModels

    weak var viewController: KYCDocumentPickerViewController?

    // MARK: - KYCDocumentPickerActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let documents = actionResponse.item as? Models.Item else { return }
     
        let sections: [Models.Sections] = [
            .title,
            .documents
        ]
        
        let sectionRows: [Models.Sections: [Any]] = [
            .title: [LabelViewModel.text("Select one of the following options:")],
            .documents: documents.compactMap { return NavigationViewModel(image: .imageName($0.imageName), label: .text($0.title)) }
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentVerify(actionResponse: KYCDocumentPickerModels.Documents.ActionResponse) {
        guard let doc = actionResponse.document else { return }
        viewController?.displayVerify(responseDisplay: .init(document: doc))
    }
    
    func presentPhoto(actionResponse: KYCDocumentPickerModels.Photo.ActionResponse) {
        viewController?.displayPhoto(responseDisplay: .init())
    }

    // MARK: - Additional Helpers

}
