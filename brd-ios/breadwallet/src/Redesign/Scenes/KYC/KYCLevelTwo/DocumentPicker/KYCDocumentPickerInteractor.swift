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
            let documents: [Document] = documents ?? [.passport, .driversLicense, .idCard]
            
//            guard error == nil else {
//                self?.presenter?.presentError(actionResponse: .init(error: error))
//                return
//            }
            self?.dataStore?.documents = documents
            self?.presenter?.presentData(actionResponse: .init(item: documents))
        }
    }
    
    func selectDocument(viewAction: KYCDocumentPickerModels.Documents.ViewAction) {
        guard let index = viewAction.index,
              index < (dataStore?.documents?.count ?? 0) else {
            return
        }
        dataStore?.document = dataStore?.documents?[index]
        takePhoto(viewAction: .init())
    }
    
    func takePhoto(viewAction: KYCDocumentPickerModels.Photo.ViewAction) {
        if dataStore?.front == nil {
            presenter?.presentTakePhoto(actionResponse: .init(document: dataStore?.document, isFront: true))
        } else if dataStore?.document != .passport,
                  dataStore?.back == nil {
            presenter?.presentTakePhoto(actionResponse: .init(document: dataStore?.document, isBack: true))
        } else if dataStore?.selfie == nil {
            presenter?.presentTakePhoto(actionResponse: .init(document: dataStore?.document, isSelfie: true))
        } else {
            guard let document = dataStore?.document else { return
                
            }
            var data = KYCDocumentUploadRequestData(front: dataStore?.front,
                                                    back: dataStore?.back,
                                                    documentyType: document)
            let group = DispatchGroup()
            group.enter()
            KYCDocumentUploadWorker().executeMultipartRequest(requestData: data) { error in
                group.leave()
            }
            
            data = KYCDocumentUploadRequestData(selfie: dataStore?.selfie,
                                                documentyType: document)
            group.enter()
            KYCDocumentUploadWorker().executeMultipartRequest(requestData: data) { error in
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                print("uploaded both")
            }
        }
    }
    
    func confirmPhoto(viewAction: KYCDocumentPickerModels.ConfirmPhoto.ViewAction) {
        let photo = viewAction.photo
        if dataStore?.front == nil {
            dataStore?.front = photo
        } else if dataStore?.document != .passport,
                  dataStore?.back == nil {
            dataStore?.back = photo
        } else if dataStore?.selfie == nil {
            dataStore?.selfie = photo
        }
        takePhoto(viewAction: .init())
    }

    // MARK: - Aditional helpers
}

struct KYCDocumentUploadRequestData: RequestModelData {
    
    var front: UIImage?
    var back: UIImage?
    var selfie: UIImage?
    var documentyType: Document
    var documentNumber: String = "NOT_NEEDED_BUT_NEEDED"
    
    func getParameters() -> [String : Any] {
        let result: [String: Any?] = [
            "documenty_type": documentyType.rawValue,
            "document_number": documentNumber
        ]
        
        return result.compactMapValues { $0 }
    }
    
    func getMultipartData()  -> [MultipartMedia] {
        let result: [String: Any?] = [
            "front": front,
            "back": back,
            "selfie": selfie
        ]
        
        return result.compactMapValues { $0 }.compactMap {
            guard let image = $0.value as? UIImage,
                  let data = image.pngData() else { return nil }
            return .init(with: data, forKey: $0.key, mimeType: .jpeg, mimeFileFormat: .jpeg)
        }
    }
}

class KYCDocumentUploadWorker: BasePlainResponseWorker {
    
    override func getMethod() -> EQHTTPMethod { return .post }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.upload)
    }
    
    override func executeMultipartRequest(requestData: RequestModelData? = nil, completion: BasePlainResponseWorker.Completion?) {
        guard let uploadData = (requestData as? KYCDocumentUploadRequestData) else { return }
        
        self.data = uploadData.getMultipartData()
        super.executeMultipartRequest(requestData: requestData, completion: completion)
    }
    
}
