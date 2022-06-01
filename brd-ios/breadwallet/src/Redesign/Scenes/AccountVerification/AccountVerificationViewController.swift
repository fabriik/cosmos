//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AccountVerificationViewController: BaseTableViewController<AccountVerificationCoordinator,
                                         AccountVerificationInteractor,
                                         AccountVerificationPresenter,
                                         AccountVerificationStore>,
                                         AccountVerificationResponseDisplays {
    typealias Models = AccountVerificationModels

    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.title = "Account Verification"
        tableView.register(WrapperTableViewCell<VerificationView>.self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
            
        case .verificationLevel:
            cell = self.tableView(tableView, verificationCellForRowAt: indexPath)

        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, verificationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? VerificationViewModel,
              let cell: WrapperTableViewCell<VerificationView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        cell.setup { view in
            view.setup(with: model)
            let config = [
                Presets.VerificationView.verified,
                Presets.VerificationView.pending,
                Presets.VerificationView.resubmit
            ][indexPath.row]
            view.configure(with: config)
        }
        cell.setupCustomMargins(all: .extraSmall)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // interactor?.navigate(viewAction: .init(index: indexPath.row))
    }

    // MARK: - User Interaction

    // MARK: - AccountVerificationResponseDisplay

    // MARK: - Additional Helpers
}
