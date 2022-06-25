//
//  RegistrationViewController.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationViewController: BaseTableViewController<RegistrationCoordinator,
                                  RegistrationInteractor,
                                  RegistrationPresenter,
                                  RegistrationStore>,
                                  RegistrationResponseDisplays {
    typealias Models = RegistrationModels

    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .email:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                view.configure(with: Presets.TextField.email)
            }
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    override func textFieldDidUpdate(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(item: text))
    }
    
    override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }

    // MARK: - RegistrationResponseDisplay
    func displayValidate(responseDisplay: RegistrationModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Section.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton>
        else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.isValid
    }
    
    func displayNext(responseDisplay: RegistrationModels.Next.ResponseDisplay) {
        coordinator?.showRegistrationConfirmation(for: responseDisplay.email)
    }

    // MARK: - Additional Helpers
}
