//
//  RegistrationConfirmationViewController.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationViewController: BaseTableViewController<RegistrationCoordinator,
                                              RegistrationConfirmationInteractor,
                                              RegistrationConfirmationPresenter,
                                              RegistrationConfirmationStore>,
                                              RegistrationConfirmationResponseDisplays {
    
    typealias Models = RegistrationConfirmationModels

    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        tableView.register(WrapperTableViewCell<CodeInputView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .title, .instructions:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .input:
            cell = self.tableView(tableView, codeInputCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        case .help:
            cell = self.tableView(tableView, buttonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, codeInputCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CodeInputView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.valueChanged = { [weak self] text in
                self?.textFieldDidFinish(for: indexPath, with: text)
            }
            view.contentSizeChanged = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, buttonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<ScrollableButtonsView> else {
            return cell
        }
        
        cell.wrappedView.callbacks = [
            resendCodeTapped,
            changeEmailTapped
        ]
        
        return cell
    }

    // MARK: - User Interaction
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(item: text))
    }
    
    override func buttonTapped() {
        interactor?.confirm(viewAction: .init())
    }
    
    private func resendCodeTapped() {
        interactor?.resend(viewAction: .init())
    }
    
    private func changeEmailTapped() {
        coordinator?.showChangeEmail()
    }

    // MARK: - RegistrationConfirmationResponseDisplay
    func displayValidate(responseDisplay: RegistrationConfirmationModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Section.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton>
        else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.isValid
    }
    
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay) {
        coordinator?.showOverlay(with: .success) { [weak self] in
            self?.coordinator?.goBack()
        }
    }
    
    func displayResend(responseDisplay: RegistrationConfirmationModels.Resend.ResponseDisplay) {
        
    }
    
    // MARK: - Additional Helpers
}
