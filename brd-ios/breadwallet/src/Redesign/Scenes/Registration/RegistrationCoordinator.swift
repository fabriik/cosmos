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
        open(scene: Scenes.RegistrationConfirmation) { vc in
            vc.dataStore?.email = email
            vc.prepareData()
        }
    }
    
    func showChangeEmail() {
        open(scene: Scenes.Registration) { vc in
            vc.dataStore?.type = .resend
            vc.prepareData()
        }
    }
    
    override func goBack() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
    // MARK: - Aditional helpers
}
