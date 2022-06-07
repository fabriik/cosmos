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
}

protocol KYCDocumentPickerActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol KYCDocumentPickerResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol KYCDocumentPickerDataStore: BaseDataStore, FetchDataStore {
    var country: String? { get set }
}

protocol KYCDocumentPickerDataPassing {
    var dataStore: KYCDocumentPickerDataStore? { get }
}

protocol KYCDocumentPickerRoutes: CoordinatableRoutes {
}
