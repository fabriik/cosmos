//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AccountVerificationCoordinator: BaseCoordinator, AccountVerificationRoutes {
    // MARK: - AccountVerificationRoutes
    
    func showPersonalInfo() {
        open(scene: Scenes.PersonalInfo)
    }

    // MARK: - Aditional helpers
}
