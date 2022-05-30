//
//  PersonalInfoViewController.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class PersonalInfoViewController: BaseTableViewController<PersonalInfoCoordinator,
                                  PersonalInfoInteractor,
                                  PersonalInfoPresenter,
                                  PersonalInfoStore>,
                                  PersonalInfoResponseDisplays {
    typealias Models = PersonalInfoModels

    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.register(WrapperTableViewCell<NameView>.self)
        navigationItem.title = "bla bla again"
        title = "bla bla"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .name:
            cell = self.tableView(tableView, nameCellForRowAt: indexPath)
            
        case .country, .birthdate:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .small)
        
        return cell
    }
    // MARK: - User Interaction

    // MARK: - PersonalInfoResponseDisplay

    // MARK: - Additional Helpers
}
