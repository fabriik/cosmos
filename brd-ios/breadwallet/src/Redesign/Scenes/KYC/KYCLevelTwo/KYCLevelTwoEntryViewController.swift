// 
//  KYCLevelTwoEntryViewController.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let KYCLevelTwo = KYCLevelTwoEntryViewController.self
}

class KYCLevelTwoEntryViewController: CheckListViewController {
    // TODO: localized
    override var sceneTitle: String? { return "We need to confirm your ID" }
    override var checklistTitle: LabelViewModel { return .text("Before you start, please:") }
    override var checkmarks: [ChecklistItemViewModel] { return [
        .init(title: .text("Prepare a valid government-issued identity document (Passport, National ID card or Drivers license)")),
        .init(title: .text("Make sure you are in a well-lit room")),
        .init(title: .text("Be prepared to take a selfie and photos of your ID"))
        ]
    }
    
    override func confirmTapped(_ sender: UIButton?) {
        (coordinator as? KYCCoordinator)?.showIdentitySelector()
    }
}
