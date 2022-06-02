//
//  DemoViewController.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit
import WalletKit

class DemoViewController: BaseTableViewController<DemoCoordinator,
                          DemoInteractor,
                          DemoPresenter,
                          DemoStore>,
                          DemoResponseDisplays {
    typealias Models = DemoModels
    
    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<VerificationView>.self)
        tableView.register(WrapperTableViewCell<DateView>.self)
    }
    
    override func prepareData() {
        sections = [
            Models.Section.date,
            Models.Section.verification,
            Models.Section.profile,
            Models.Section.infoView,
            Models.Section.navigation,
            Models.Section.textField,
            Models.Section.label,
            Models.Section.button
        ]
        
        sectionRows = [
            Models.Section.date: [
                DateViewModel()
            ],
            Models.Section.verification: [
                VerificationViewModel(title: .text("ACCOUNT VERIFICATION"),
                                      status: .none,
                                      infoButton: .init(image: "infoIcon"),
                                      description: .text("Upgrade your limits and get full access!"),
                                      bottomButton: .init(title: "Verify your account")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .resubmit,
                                      infoButton: .init(image: "infoIcon"),
                                      description: .text("Basic ($1,000/day)"),
                                      bottomButton: .init(title: "Upgrade your limits")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .pending,
                                      infoButton: .init(image: "infoIcon"),
                                      description: .text("Unlimited (Unlimited transaction amounts)")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .verified,
                                      infoButton: .init(image: "infoIcon"),
                                      description: .text("Unlimited (Unlimited transaction amounts)"))
            ],
            Models.Section.profile: [
                ProfileViewModel(name: "Rok", image: "stars")
            ],
            Models.Section.navigation: [
                NavigationViewModel(image: .imageName("lock_closed"),
                                    label: .text("Security settings"),
                                    button: .init(image: "arrow_right")),
                NavigationViewModel(image: .imageName("settings"),
                                    label: .text("Security settings"),
                                    button: .init(image: "arrow_right")),
                NavigationViewModel(image: .imageName("withdrawal"),
                                    label: .text("Export transaction history to csv"),
                                    button: .init(image: "arrow_right"))
            ],
            Models.Section.button: [
                "Click me!!",
                "Dont Click me please!!"
            ],
            
            Models.Section.textField: [
                TextFieldModel(title: "First name", hint: "Your mama gave it to you", validator: { string in
                    return (string ?? "").count > 3
                }),
                TextFieldModel(title: "Last name"),
                TextFieldModel(title: "Email", placeholder: "smth@smth_else.com", error: "cant be empty"),
                TextFieldModel(title: "Address", validator: { _ in return true })
            ],
            
            Models.Section.infoView: [
                InfoViewModel(headerLeadingImage: .imageName("ig"),
                              headerTitle: .text("This is a header title"),
                              headerTrailing: .init(image: "info"),
                              title: .text("This is a title"),
                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
                              button: .init(title: "Close"))
            ]
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - User Interaction
    // MARK: - DemoResponseDisplay
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .verification:
            cell = self.tableView(tableView, verificationCellForRowAt: indexPath)
            
        case .label:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .button:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        case .textField:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .infoView:
            cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            
        case .navigation:
            cell = self.tableView(tableView, navigationCellForRowAt: indexPath)
            
        case .profile:
            cell = self.tableView(tableView, profileViewCellForRowAt: indexPath)
            
        case .date:
            cell = self.tableView(tableView, dateCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, dateCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<DateView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: .init())
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
                Presets.VerificationView.none,
                Presets.VerificationView.resubmit,
                Presets.VerificationView.pending,
                Presets.VerificationView.verified
            ][indexPath.row % 4]
            view.configure(with: config)
        }
        cell.setupCustomMargins(all: .extraSmall)
        
        return cell
    }
    
    // MARK: - Additional Helpers
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sections[indexPath.section].hashValue == Models.Section.label.hashValue else { return }
        
        toggleInfo()
    }
    
    func toggleInfo() {
        guard blurView?.superview == nil else {
            hideInfo()
            return
        }
        
        showInfo()
    }
    
    func showInfo() {
        // TODO: this is demo code.. no review required XD
        toggleBlur(animated: true)
        guard let blur = blurView else { return }
        let popup = FEPopupView()
        view.insertSubview(popup, aboveSubview: blur)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.snp.topMargin)
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.layoutIfNeeded()
        popup.alpha = 0
        
        var text = "almost done... "
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        
        popup.configure(with: Presets.Popup.normal)
        popup.setup(with: .init(title: .text("This is a title"),
                                body: text,
                                buttons: [
                                    .init(title: "Donate"),
                                    .init(title: "Donate", image: "close"),
                                    .init(image: "close")
                                ]))
        popup.closeCallback = { [weak self] in
            self?.hideInfo()
        }
        
        popup.buttonCallbacks = [
            { print("Donated 10$! Thanks!") }
        ]
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 1
        }
    }
    
    @objc func hideInfo() {
        guard let popup = view.subviews.first(where: { $0 is FEPopupView }) else { return }
        
        toggleBlur(animated: true)
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 0
        } completion: { _ in
            popup.removeFromSuperview()
        }
    }
}
