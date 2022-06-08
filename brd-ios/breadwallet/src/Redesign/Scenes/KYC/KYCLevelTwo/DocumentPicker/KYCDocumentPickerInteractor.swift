//
//  KYCDocumentPickerInteractor.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

class KYCDocumentPickerInteractor: NSObject, Interactor, KYCDocumentPickerViewActions {
    typealias Models = KYCDocumentPickerModels

    var presenter: KYCDocumentPickerPresenter?
    var dataStore: KYCDocumentPickerStore?

    // MARK: - KYCDocumentPickerViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        KYCDocumentWorker().execute { [weak self] documents, error in
            guard let documents = documents, error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            self?.dataStore?.documents = documents
            self?.presenter?.presentData(actionResponse: .init(item: documents))
        }
    }
    
    func verify(viewAction: KYCDocumentPickerModels.Documents.ViewAction) {
        guard let index = viewAction.index,
              index < (dataStore?.documents?.count ?? 0) else {
            return
        }
        presenter?.presentVerify(actionResponse: .init(document: dataStore?.documents?[index]))
    }

    // MARK: - Aditional helpers
}
