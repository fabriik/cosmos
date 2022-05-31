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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, infoViewCellForRowAt: indexPath)
        guard let cell = cell as? WrapperTableViewCell<WrapperView<FEInfoView>>
        else { return cell }
        
        cell.setup { view in
            view.setup { view in
                view.headerButtonCallback = { [weak self] in
                    self?.interactor?.showVerificationInfo(viewAction: .init())
                }
                
                view.trailingButtonCallback = { [weak self] in
                    self?.coordinator?.openModally(coordinator: AccountVerificationCoordinator.self, scene: Scenes.AccountVerification)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, profileViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, profileViewCellForRowAt: indexPath)
        guard let cell = cell as? WrapperTableViewCell<ProfileView>
        else { return cell }
        
        cell.setup { view in
            view.editImageCallback = { [weak self] in
                self?.coordinator?.showAvatarSelection()
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.navigate(viewAction: .init(index: indexPath.row))
    }
    
    // MARK: - User Interaction
    
    // MARK: - ProfileResponseDisplay
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay) {
        coordinator?.showUnderConstruction(responseDisplay.item.rawValue)
    }
    
    // MARK: - Additional Helpers
}
