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
        dataStore?.document = dataStore?.documents?[index]
        presenter?.presentVerify(actionResponse: .init(document: dataStore?.document))
    }
    
    func photo(viewAction: KYCDocumentPickerModels.Photo.ViewAction) {
        if dataStore?.front == nil {
            presenter?.presentPhoto(actionResponse: .init(isFront: true))
        } else if dataStore?.document != .passport,
                  dataStore?.back == nil {
            presenter?.presentPhoto(actionResponse: .init(isBack: true))
        } else if dataStore?.selfie == nil {
            presenter?.presentPhoto(actionResponse: .init(isSelfie: true))
        } else { // finish flow! }
    }
    
    func confirmPhoto(viewAction: KYCDocumentPickerModels.ConfirmPhoto.ViewAction) {
        if !viewAction.isConfirmed {
          // nothing happens here :D 
        } else if dataStore?.front == nil {
            dataStore?.front = dataStore?.photo
        } else if dataStore?.document != .passport,
                  dataStore?.back == nil {
            dataStore?.back = dataStore?.photo
        } else if dataStore?.selfie == nil {
            dataStore?.selfie = dataStore?.photo
        }
        dataStore?.photo = nil
        photo(viewAction: .init())
    }

    // MARK: - Aditional helpers
}
