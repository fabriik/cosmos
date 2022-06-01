//
//  PersonalInfoViewController.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class PersonalInfoViewController: BaseTableViewController<ProfileCoordinator,
                                  PersonalInfoInteractor,
                                  PersonalInfoPresenter,
                                  PersonalInfoStore>,
                                  PersonalInfoResponseDisplays {
    typealias Models = PersonalInfoModels

    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.register(WrapperTableViewCell<NameView>.self)
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
    
    override func tableView(_ tableView: UITableView, textFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, textFieldCellForRowAt: indexPath)
        let section = sections[indexPath.section] as? Models.Section
        
        guard let cell = cell as? WrapperTableViewCell<FETextField>,
              section == .country
        else { return cell }
        
        cell.setup { view in
            view.configure(with: Presets.TexxtField.two)
            view.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] as? Models.Section {
        case .country:
            coordinator?.showCountrySelector() { [weak self] code in
                print("selected \(code)")
                self?.interactor?.countrySelected(viewAction: .init(code: code))
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        default:
            return
        }
    }
    
    // MARK: - User Interaction

    // MARK: - PersonalInfoResponseDisplay

    // MARK: - Additional Helpers
}
