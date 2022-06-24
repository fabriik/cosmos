//
//  ProfileViewController.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

class ProfileViewController: BaseTableViewController<ProfileCoordinator,
                             ProfileInteractor,
                             ProfilePresenter,
                             ProfileStore>,
                             ProfileResponseDisplays {
    typealias Models = ProfileModels
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .profile:
            cell = self.tableView(tableView, profileViewCellForRowAt: indexPath)
            
        case .verification:
            cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            
        case .navigation:
            cell = self.tableView(tableView, navigationCellForRowAt: indexPath)

        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                view.setup(with: model)
                
                let config: InfoViewConfiguration
                switch (model.kyc, model.status) {
                    
                case (.levelOne, .levelOne),
                    (.levelTwo, .levelTwo(.levelTwo)):
                    config = Presets.InfoView.verified
                    
                case (.levelTwo, .levelTwo(.submitted)):
                    config = Presets.InfoView.pending
                    
                case (.levelTwo, .levelTwo(.resubmit)),
                    (.levelTwo, .levelTwo(.declined)),
                    (.levelTwo, .levelTwo(.expired)):
                    config = Presets.InfoView.declined
                    
                default:
                    config = Presets.InfoView.verification
                }
                
                view.configure(with: config)
                
                view.setupCustomMargins(all: .large)
                view.headerButtonCallback = { [weak self] in
                    self?.interactor?.showVerificationInfo(viewAction: .init())
                }
                
                view.trailingButtonCallback = { [weak self] in
                    self?.coordinator?.showVerificationScreen(for: self?.dataStore?.profile)
                }
            }
            view.setupCustomMargins(all: .large)
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] as? Models.Section {
        case .navigation:
            interactor?.navigate(viewAction: .init(index: indexPath.row))
        default:
            return
        }
    }
    
    // MARK: - User Interaction
    
    // MARK: - ProfileResponseDisplay
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay) {
        switch responseDisplay.item {
        case .preferences:
            coordinator?.showPreferences()
            
        case .security:
            coordinator?.showSecuirtySettings()
        }
    }
    
    // MARK: - Additional Helpers
}
