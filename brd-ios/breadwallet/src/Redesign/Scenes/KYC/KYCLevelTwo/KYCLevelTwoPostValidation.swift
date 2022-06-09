//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension Scenes {
    static let KYCLevelTwoPostValidation = KYCLevelTwoPostValidationViewController.self
}

class KYCLevelTwoPostValidationViewController: CheckListViewController {
    // TODO: localized
    override var sceneTitle: String? { return "Your ID verification is in progress" }
    override var checklistTitle: LabelViewModel { return .text("We are reviewing your documents and will let you know when your account has been verified.") }
    override var checkmarks: [ChecklistItemViewModel] { return [
        .init(title: .text("Uploading your photos")),
        .init(title: .text("Checking for errors")),
        .init(title: .text("Sending your data for verification")),
        .init(title: .text("Verifying you"))
    ]
    }
    
    override func confirmTapped(_ sender: UIButton?) {
        (coordinator as? KYCCoordinator)?.goBack()
    }
}
