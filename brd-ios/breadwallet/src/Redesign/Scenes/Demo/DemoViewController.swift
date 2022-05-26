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
        
    }
    
    override func prepareData() {
        sections = [
            Models.Section.profile,
            Models.Section.infoView,
            Models.Section.navigation,
            //            Models.Section.textField,
            //            Models.Section.label,
            //            Models.Section.button
        ]
        
        sectionRows = [
            Models.Section.profile: [
                ProfileViewModel(name: "Rok", image: "stars")
            ],
            Models.Section.infoView: [
                InfoViewModel(headerLeadingImage: .imageName("ig"),
                              headerTitle: .text("This is a header title"),
                              headerTrailingImage: .imageName("user"),
                              title: .text("This is a title"),
                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
                              button: .init(title: "Close")),
            ],
            Models.Section.navigation: [
                ImageLabelModel(image: .imageName("lock_closed"),
                                label: .text("Security settings"),
                                button: .init(image: "arrow_right")),
                ImageLabelModel(image: .imageName("settings"),
                                label: .text("Security settings"),
                                button: .init(image: "arrow_right")),
                ImageLabelModel(image: .imageName("withdrawal"),
                                label: .text("Export transaction history to csv"),
                                button: .init(image: "arrow_right")),
            ],
        ]
        //            Models.Section.button: [
        //                "Click me!!",
        //                "Dont Click me please!!"
        //            ],
        //
        //            Models.Section.textField: [
        //                TextFieldModel(title: "First name", hint: "Your mama gave it to you", validator: { string in
        //                    return (string ?? "").count > 3
        //                }),
        //                TextFieldModel(title: "Last name"),
        //                TextFieldModel(title: "Email", placeholder: "smth@smth_else.com", error: "cant be empty"),
        //                TextFieldModel(title: "Address", validator: { _ in return true })
        //            ],
        //
        //            Models.Section.infoView: [
        //                InfoViewModel(headerLeadingImage: .image("ig"),
        //                              headerTitle: .text("This is a header title"),
        //                              headerTrailingImage: .image("user"),
        //                              title: .text("This is a title"),
        //                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
        //                              button: .init(title: "Close")),
        //
        //                InfoViewModel(headerTitle: .text("This is a header title"),
        //                              headerTrailingImage: .image("user"),
        //                              title: .text("This is a title"),
        //                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
        //                              button: .init(title: "Close")),
        //
        //                InfoViewModel(headerLeadingImage: .image("ig"),
        //                              headerTrailingImage: .image("user"),
        //                              title: .text("This is a title"),
        //                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
        //                              button: .init(title: "Close")),
        //
        //                InfoViewModel(headerLeadingImage: .image("ig"),
        //                              headerTitle: .text("This is a header title"),
        //                              headerTrailingImage: .image("user"),
        //                              description: .text("This is a description. It can be long and should break up in multiple lines by word wrapping."),
        //                              button: .init(title: "Close"))
        //            ]
        //        ]
        
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
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Additional Helpers
}
