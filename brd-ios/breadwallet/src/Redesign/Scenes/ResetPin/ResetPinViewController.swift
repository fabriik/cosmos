//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class ResetPinViewController: BaseTableViewController<ResetPinCoordinator,
                              ResetPinInteractor,
                              ResetPinPresenter,
                              ResetPinStore>,
                              ResetPinResponseDisplays {
    
    typealias Models = ResetPinModels

    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .button:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction
    override func buttonTapped() {
        super.buttonTapped()
        
    }

    // MARK: - ResetPinResponseDisplay

    // MARK: - Additional Helpers
}
