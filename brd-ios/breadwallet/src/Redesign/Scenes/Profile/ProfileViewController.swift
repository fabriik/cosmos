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
            view.wrappedView.headerButtonCallback = { [weak self] in
                self?.showInfo()
            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    // MARK: - ProfileResponseDisplay
    
    // MARK: - Additional Helpers
    func showInfo() {
        // TODO: this is demo code.. no review required XD
        toggleBlur(animated: true)
        guard let blur = blurView else { return }
        let popup = FEPopupView()
        view.insertSubview(popup, aboveSubview: blur)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.layoutIfNeeded()
        popup.alpha = 0
        
        let text = """
If you verify your account, you are given acces to:
  - Unlimited deposits/withdraws
  - Enhanced security
  - Full asset support
  - Buy crypto with card
  - 24/7/365 live customer support
"""
        
        popup.configure(with: Presets.Popup.normal)
        popup.setup(with: .init(title: .text("Why should I verify my account?"),
                                body: text,
                                buttons: [
                                    .init(title: "Verify my account", image: "profile")
                                ]))
        
        popup.closeCallback = { [weak self] in
            self?.hideInfo()
        }
        
        popup.buttonCallbacks = [
            {print("Donated 10$! Thanks!")}
        ]
        
        UIView.animate(withDuration: 0.25) {
            popup.alpha = 1
        }
    }
    
    @objc func hideInfo() {
        guard let popup = view.subviews.first(where: { $0 is FEPopupView }) else { return }
        
        toggleBlur(animated: true)
        
        UIView.animate(withDuration: 0.25) {
            popup.alpha = 0
        } completion: { _ in
            popup.removeFromSuperview()
        }
    }
}
