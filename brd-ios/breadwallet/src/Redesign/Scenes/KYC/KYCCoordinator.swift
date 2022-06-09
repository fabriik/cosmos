// 
//  KYCCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class KYCCoordinator: BaseCoordinator, KYCBasicRoutes, KYCDocumentPickerRoutes, ImagePickable {
    
    var photoSelected: ((UIImage) -> Void)?
    
    override func start() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showCountrySelector(selected: ((String?) -> Void)?) {
        let nvc = UINavigationController()
        let coordinator = ItemSelectionCoordinator(navigationController: nvc)
        coordinator.start()
        coordinator.parentCoordinator = self
        (nvc.topViewController as? ItemSelectionViewController)?.itemSelected = selected
        childCoordinators.append(coordinator)
        navigationController.show(nvc, sender: nil)
    }
    
    func showKYCLevelOne() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showKYCLevelTwo() {
        open(scene: Scenes.KYCLevelTwo)
    }
    
    func showIdentitySelector() {
        open(scene: Scenes.KYCDocumentPicker)
    }
    
    func showDocumentVerification(for document: Document) {
        showUnderConstruction("\(document.title) verification")
    }
    
    func showLevelTwoValidation() {
        open(scene: Scenes.KYCLevelTwoPostValidation)
    }
    
    override func goBack() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
}
