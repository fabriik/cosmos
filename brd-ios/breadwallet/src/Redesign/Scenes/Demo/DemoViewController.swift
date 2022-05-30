//
//  DemoViewController.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit

class DemoViewController: BaseTableViewController<DemoCoordinator,
                          DemoInteractor,
                          DemoPresenter,
                          DemoStore>,
                          DemoResponseDisplays {
    typealias Models = DemoModels
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.register(WrapperTableViewCell<NameView>.self)
    }
    
    override func prepareData() {
        sections = [
            Models.Section.name
//            Models.Section.profile,
//            Models.Section.infoView,
//            Models.Section.navigation,
//            Models.Section.textField,
//            Models.Section.label,
//            Models.Section.button
        ]
        
        sectionRows = [
            Models.Section.name: [
                NameViewModel(title: .text("You got it at birth"),
                              firstName: .init(title: "First name"),
                              lastName: .init(title: "Last name"))
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
            
        case .name:
            cell = self.tableView(tableView, nameCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Additional Helpers

    func tableView(_ tableView: UITableView, nameCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<NameView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? NameViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.contentSizeChanged = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        toggleInfo()
//    }
    
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
