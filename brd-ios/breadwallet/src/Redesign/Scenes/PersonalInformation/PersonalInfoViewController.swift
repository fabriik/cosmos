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
        
        navigationItem.title = "bla bla again"
        title = "bla bla"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .instructions:
            cell = super.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .name, .country, .birthdate:
            cell = super.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .confirm:
            cell = super.tableView(tableView, buttonCellForRowAt: indexPath)
            
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
