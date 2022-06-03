//
//  RegistrationCoordinator.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationCoordinator: BaseCoordinator, RegistrationRoutes {
    // MARK: - RegistrationRoutes
    override func start() {
        open(scene: Scenes.Registration)
    }
    
    func showRegistrationConfirmation() {
        let controller = RegistrationConfirmationViewController()
        controller.coordinator = self
        navigationController.show(controller, sender: nil)
    }
    
    func showChangeEmail() {
        let controller = RegistrationViewController()
        controller.dataStore?.type = .resend
        controller.prepareData()
        controller.coordinator = self
        navigationController.show(controller, sender: nil)
    }

    // MARK: - Aditional helpers
}
