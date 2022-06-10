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
            let data = KYCDocumentUploadRequestData(front: dataStore?.front,
                                                    back: dataStore?.back,
                                                    documentyType: document)
            let selfie = dataStore?.selfie
            
            KYCDocumentUploadWorker().executeMultipartRequest(requestData: data) { [weak self] error in
                guard error == nil else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                let data = KYCDocumentUploadRequestData(selfie: selfie, documentyType: .selfie)
                KYCDocumentUploadWorker().executeMultipartRequest(requestData: data) { error in
                    guard error == nil else {
                        self?.presenter?.presentError(actionResponse: .init(error: error))
                        return
                    }
                    self?.presenter?.presentFinish(actionResponse: .init())
                }
            }
        }
    }
    
    func confirmPhoto(viewAction: KYCDocumentPickerModels.ConfirmPhoto.ViewAction) {
        ImageCompressor.compress(image: viewAction.photo, maxByte: 512*512) { [unowned self] image, _ in
            if dataStore?.front == nil {
                dataStore?.front = image
            } else if dataStore?.document != .passport,
                      dataStore?.back == nil {
                dataStore?.back = image
            } else if dataStore?.selfie == nil {
                dataStore?.selfie = image
            }
            takePhoto(viewAction: .init())
        }
    }

    // MARK: - Aditional helpers
}

struct ImageCompressor {
    static func compress(image: UIImage?, maxByte: Int, completion: @escaping (UIImage?, Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = image,
                  let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else { return }
            
            var iterationImage: UIImage? = image
            var iterationImageData: Data?
            
            var iterationImageSize = currentImageSize
            var iterationCompression: CGFloat = 1.0
            
            if iterationImageSize <= maxByte && iterationCompression > 0.01 {
                DispatchQueue.main.async {
                    completion(iterationImage, iterationImage?.jpegData(compressionQuality: 1.0))
                }
            }
            
            while iterationImageSize > maxByte && iterationCompression > 0.01 {
                let percantageDecrease = getPercantageToDecreaseTo(forDataCount: iterationImageSize)
                
                let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                        height: image.size.height * iterationCompression)
                UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
                defer { UIGraphicsEndImageContext() }
                image.draw(in: CGRect(origin: .zero, size: canvasSize))
                iterationImage = UIGraphicsGetImageFromCurrentImageContext()
                iterationImageData = iterationImage?.jpegData(compressionQuality: 1.0)
                
                guard let newImageSize = iterationImage?.jpegData(compressionQuality: 1.0)?.count else { return }
                iterationImageSize = newImageSize
                iterationCompression -= percantageDecrease
            }
            
            DispatchQueue.main.async {
                completion(iterationImage, iterationImageData)
            }
        }
    }
    
    private static func getPercantageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0..<3_000_000: return 0.05
        case 3_000_000..<10_000_000: return 0.1
        default: return 0.2
        }
    }
}
