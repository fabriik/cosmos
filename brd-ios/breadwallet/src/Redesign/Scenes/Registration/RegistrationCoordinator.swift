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
        showUnderConstruction("email confirmation")
    }

    // MARK: - Aditional helpers
}
