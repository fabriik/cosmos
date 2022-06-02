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
            
        case .title, .instructions:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .email:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, coverCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<FEImageView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ImageViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: Presets.Background.transparent)
            view.setup(with: model)
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(item: text))
    }
    
    override func buttonTapped() {
        interactor?.next(viewACtion: .init())
    }

    // MARK: - RegistrationResponseDisplay
    func displayValidate(responseDisplay: RegistrationModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Section.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton>
        else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.isValid
    }
    
    func displayNext(responseDisplay: RegistrationModels.Next.ResponseDisplay) {
        coordinator?.showRegistrationConfirmation()
    }

    // MARK: - Additional Helpers
}
