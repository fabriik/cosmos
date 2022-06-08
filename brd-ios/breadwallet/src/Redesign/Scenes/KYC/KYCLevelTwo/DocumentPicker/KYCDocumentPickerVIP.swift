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
}

protocol KYCDocumentPickerActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerify(actionResponse: KYCDocumentPickerModels.Documents.ActionResponse)
}

protocol KYCDocumentPickerResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayVerify(responseDisplay: KYCDocumentPickerModels.Documents.ResponseDisplay)
}

protocol KYCDocumentPickerDataStore: BaseDataStore, FetchDataStore {
    var documents: [Document]? { get set }
}

protocol KYCDocumentPickerDataPassing {
    var dataStore: KYCDocumentPickerDataStore? { get }
}

protocol KYCDocumentPickerRoutes: CoordinatableRoutes {
    func showDocumentVerification(for document: Document)
}
