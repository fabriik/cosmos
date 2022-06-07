//
//  KYCDocumentPickerVIP.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

extension Scenes {
    static let KYCDocumentPicker = KYCDocumentPickerViewController.self
}

protocol KYCDocumentPickerViewActions: BaseViewActions, FetchViewActions {
    func verify(viewAction: KYCDocumentPickerModels.Documents.ViewAction)
    func photo(viewAction: KYCDocumentPickerModels.Photo.ViewAction)
    func confirmPhoto(viewAction: KYCDocumentPickerModels.ConfirmPhoto.ViewAction)
}

protocol KYCDocumentPickerActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerify(actionResponse: KYCDocumentPickerModels.Documents.ActionResponse)
    func presentPhoto(actionResponse: KYCDocumentPickerModels.Photo.ActionResponse)
}

protocol KYCDocumentPickerResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayVerify(responseDisplay: KYCDocumentPickerModels.Documents.ResponseDisplay)
    func displayPhoto(responseDisplay: KYCDocumentPickerModels.Photo.ResponseDisplay)
}

protocol KYCDocumentPickerDataStore: BaseDataStore, FetchDataStore {
    var documents: [Document]? { get set }
    var front: UIImage? { get set }
    var back: UIImage? { get set }
    var selfie: UIImage? { get set }
}

protocol KYCDocumentPickerDataPassing {
    var dataStore: KYCDocumentPickerDataStore? { get }
}

protocol KYCDocumentPickerRoutes: CoordinatableRoutes {
    func showDocumentVerification(for document: Document)
}
