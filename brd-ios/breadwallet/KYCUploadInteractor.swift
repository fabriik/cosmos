// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCUploadBusinessLogic {
    // MARK: Business logic functions
    
    func saveImage(request: KYCUpload.SaveImages.Request)
    func setImage(request: KYCUpload.SetImage.Request)
}

protocol KYCUploadDataStore {
    // MARK: Data store
    
    var images: [KYCUploadViewController.Step: Data] { get set }
}

class KYCUploadInteractor: KYCUploadBusinessLogic, KYCUploadDataStore {
    var presenter: KYCUploadPresentationLogic?
    
    // MARK: Interactor functions
    
    var images = [KYCUploadViewController.Step: Data]()
    
    func setImage(request: KYCUpload.SetImage.Request) {
        guard let image = request.image.resized(withPercentage: 0.5, isOpaque: false)?.jpegData(compressionQuality: 0.7) else { return }
        images[request.step] = image
    }
    
    func saveImage(request: KYCUpload.SaveImages.Request) {
        switch request.step {
        case .idSelfie:
            guard let selfieImage = images[.idSelfie] else { return }
            uploadSelfie(image: [.idSelfie: selfieImage])
            
        case .idBack:
            guard let frontImage = images[.idFront], let backImage = images[.idBack] else { return }
            uploadFrontBack(images: [.idFront: frontImage, .idBack: backImage])
            
        default:
            break
        }
    }
    
    private func uploadSelfie(image: [KYCUploadViewController.Step: Data]) {
        let worker = KYCUploadSelfieWorker()
        let workerUrlModelData = KYCUploadSelfieWorkerUrlModelData()
        let workerRequest = KYCUploadSelfieWorkerRequest(imageData: image)
        let workerData = KYCUploadSelfieWorkerData(workerRequest: workerRequest,
                                                   workerUrlModelData: workerUrlModelData)
        
        worker.executeMultipartRequest(requestData: workerData) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }
            
            self?.presenter?.presentSaveImage(response: .init())
        }
    }
    
    private func uploadFrontBack(images: [KYCUploadViewController.Step: Data]) {
        let worker = KYCUploadFrontBackWorker()
        let workerUrlModelData = KYCUploadFrontBackWorkerUrlModelData()
        let workerRequest = KYCUploadFrontBackWorkerRequest(imageData: images)
        let workerData = KYCUploadFrontBackWorkerData(workerRequest: workerRequest,
                                                      workerUrlModelData: workerUrlModelData)
        
        worker.executeMultipartRequest(requestData: workerData) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }
            
            self?.presenter?.presentSaveImage(response: .init())
        }
    }
}
