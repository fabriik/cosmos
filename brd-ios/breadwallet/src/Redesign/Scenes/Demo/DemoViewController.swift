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
        
        tableView.register(WrapperTableViewCell<VerificationView>.self)
    }
    
    override func prepareData() {
        sections = [
            Models.Section.verification,
            Models.Section.textField,
            Models.Section.infoView,
            Models.Section.label,
            Models.Section.button
        ]
        
        sectionRows = [
            Models.Section.verification: [
                VerificationViewModel(title: .text("ACCOUNT VERIFICATION"),
                                      status: .none,
//                                      status: .init(),
                                      infoButton: .init(image: .init(named: "infoIcon")),
                                      description: .text("Upgrade your limits and get full access!"),
                                      bottomButton: .init(title: "Verify your account")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .limited,
//                                      status: .init(),
                                      infoButton: .init(image: .init(named: "infoIcon")),
                                      description: .text("Basic ($1,000/day)"),
                                      bottomButton: .init(title: "Upgrade your limits")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .pending,
//                                      status: .init(),
                                      infoButton: .init(image: .init(named: "infoIcon")),
                                      description: .text("Unlimited (Unlimited transaction amounts)")),
                
                VerificationViewModel(title: .text("ACCOUNT LIMITS"),
                                      status: .verified,
//                                      status: .init(),
                                      infoButton: .init(image: .init(named: "infoIcon")),
                                      description: .text("Unlimited (Unlimited transaction amounts)"))
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
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
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
                Presets.VerificationView.limited,
                Presets.VerificationView.pending,
                Presets.VerificationView.verified
            ][indexPath.row % 4]
            view.configure(with: config)
        }
        cell.setupCustomMargins(all: .extraSmall)
        
        return cell
    }
    
    // MARK: - Additional Helpers
}
