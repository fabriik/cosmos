//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension Scenes {
    static let KYCLevelTwoPostValidation = KYCLevelTwoPostValidationViewController.self
}

class KYCLevelTwoPostValidationViewController: CheckListViewController {
    // TODO: localized
    override var sceneLeftAlignedTitle: String? { return "Your ID verification is in progress" }
    override var checklistTitle: LabelViewModel { return .text("We are reviewing your documents and will let you know when your account has been verified.") }
    override var checkmarks: [ChecklistItemViewModel] { return [
        .init(title: .text("Uploading your photos")),
        .init(title: .text("Checking for errors")),
        .init(title: .text("Sending your data for verification")),
        .init(title: .text("Verifying you"))
    ]
    }
    
    override func prepareData() {
        super.prepareData()
        
        confirmButton.setup(with: .init(title: "Continue"))
    }
    
    override func confirmTapped(_ sender: UIButton?) {
        UserManager.shared.refresh { [weak self] _ in
            (self?.coordinator as? KYCCoordinator)?.dismissFlow()
        }
    }
}
