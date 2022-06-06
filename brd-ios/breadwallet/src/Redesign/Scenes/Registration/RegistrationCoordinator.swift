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
            guard let email = UserDefaults.email else {
            return open(scene: Scenes.Registration)
        }
            
        showRegistrationConfirmation(for: email)
    }
    
    func showRegistrationConfirmation(for email: String?) {
        let controller = RegistrationConfirmationViewController()
        controller.coordinator = self
        controller.dataStore?.email = email
        navigationController.show(controller, sender: nil)
    }
    
    func showChangeEmail() {
        let controller = RegistrationViewController()
        controller.dataStore?.type = .resend
        controller.prepareData()
        controller.coordinator = self
        navigationController.show(controller, sender: nil)
    }

    override func goBack() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
    // MARK: - Aditional helpers
}
