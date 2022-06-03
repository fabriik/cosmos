//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class VerifyAccountViewController: BaseTableViewController<VerifyAccountCoordinator,
                                   VerifyAccountInteractor,
                                   VerifyAccountPresenter,
                                   VerifyAccountStore>,
                                   VerifyAccountResponseDisplays {
    
    typealias Models = VerifyAccountModels

    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .title, .description:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .verifyButton:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        coordinator?.showRegistration()
    }

    // MARK: - VerifyAccountResponseDisplay

    // MARK: - Additional Helpers
}