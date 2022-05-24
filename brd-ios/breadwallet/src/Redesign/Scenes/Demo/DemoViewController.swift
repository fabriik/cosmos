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
    
    override func prepareData() {
        sections = [
            Models.Section.textField,
            Models.Section.infoView,
            Models.Section.label,
            Models.Section.button
        ]
        
        sectionRows = [
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
                InfoViewModel(headerLeadingImage: .image("ig"),
                              headerTitle: .text("This is a header title"),
                              headerTrailingImage: .image("user"),
                              title: .text("This is a title"),
                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
                              button: .init(title: "Close")),
                
                InfoViewModel(headerTitle: .text("This is a header title"),
                              headerTrailingImage: .image("user"),
                              title: .text("This is a title"),
                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
                              button: .init(title: "Close")),
                
                InfoViewModel(headerLeadingImage: .image("ig"),
                              headerTrailingImage: .image("user"),
                              title: .text("This is a title"),
                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
                              button: .init(title: "Close")),
                
                InfoViewModel(headerLeadingImage: .image("ig"),
                              headerTitle: .text("This is a header title"),
                              headerTrailingImage: .image("user"),
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
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Additional Helpers
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        toggleBlur(animated: true)
        guard let blur = blurView else { return }
        let popup = FEPopupView()
        view.insertSubview(popup, aboveSubview: blur)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.snp.topMargin).inset(30)
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.layoutIfNeeded()
        popup.alpha = 0
        
        var text = "Tole se skucamo pa gremo... "
        text += text
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
                                .init(title: "Close button"),
                                .init(title: "Donate")
                               ]))
        popup.buttonCallbacks = [
            hideInfo,
            { print("Donated 10$! Thanks!") }
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
