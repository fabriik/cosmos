// 
//  KYCCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import AVFoundation
import UIKit

class KYCCoordinator: BaseCoordinator, KYCBasicRoutes, KYCDocumentPickerRoutes, DocumentReviewRoutes {
    
    override func start() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showCountrySelector(selected: ((CountryResponseData?) -> Void)?) {
        let nvc = RootNavigationController()
        let coordinator = ItemSelectionCoordinator(navigationController: nvc)
        coordinator.start()
        coordinator.parentCoordinator = self
        (nvc.topViewController as? ItemSelectionViewController)?.itemSelected = selected
        childCoordinators.append(coordinator)
        navigationController.show(nvc, sender: nil)
    }
    
    func showDocumentReview(checklist: [ChecklistItemViewModel], image: UIImage) {
        let controller = DocumentReviewViewController()
        controller.dataStore?.checklist = checklist
        controller.dataStore?.image = image
        controller.prepareData()
        controller.coordinator = self
        controller.setBarButtonItem(from: navigationController, to: .right, target: self, action: #selector(popFlow(sender:)))
        
        controller.retakePhoto = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        controller.confirmPhoto = { [weak self] in
            let picker = self?.navigationController.children.first(where: { $0 is KYCDocumentPickerViewController }) as? KYCDocumentPickerViewController
            picker?.interactor?.confirmPhoto(viewAction: .init(photo: image))
            
            LoadingView.show()
        }
        
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showKYCFinal() {
        let controller = KYCLevelTwoPostValidationViewController()
        controller.prepareData()
        controller.coordinator = self
        controller.navigationItem.setHidesBackButton(true, animated: false)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showKYCLevelOne() {
        let controller = KYCBasicViewController()
        controller.prepareData()
        controller.coordinator = self
        controller.setBarButtonItem(from: navigationController, to: .right, target: self, action: #selector(popFlow(sender:)))
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showKYCLevelTwo() {
        let controller = KYCLevelTwoEntryViewController()
        controller.prepareData()
        controller.coordinator = self
        controller.setBarButtonItem(from: navigationController, to: .right, target: self, action: #selector(popFlow(sender:)))
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showIdentitySelector() {
        let controller = KYCDocumentPickerViewController()
        controller.prepareData()
        controller.coordinator = self
        controller.setBarButtonItem(from: navigationController, to: .right)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showDocumentVerification(for document: Document) {
        showUnderConstruction("\(document.title) verification")
    }
    
    func dismissFlow() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
    
    @objc func popFlow(sender: UIBarButtonItem) {
        navigationController.popToRootViewController(animated: true)
    }
}

extension KYCCoordinator: ImagePickable {
    func showImagePicker(model: KYCCameraImagePickerModel?,
                         device: AVCaptureDevice,
                         completion: ((UIImage?) -> Void)?) {
        let controller = KYCCameraViewController()
        
        controller.defaultVideoDevice = device
        controller.configure(with: .init(instructions: .init(font: Fonts.Body.one,
                                                             textColor: LightInversedColors.Text.one,
                                                             textAlignment: .center),
                                         background: .init(backgroundColor: LightInversedColors.Background.one)))
        controller.setup(with: model)
        controller.photoSelected = completion
        controller.setBarButtonItem(from: navigationController, to: .right, target: self, action: #selector(popFlow(sender:)))
        
        navigationController.pushViewController(controller, animated: true)
    }
}
