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
        tableView.register(WrapperTableViewCell<FETest>.self)
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
                TextFieldModel(title: "This is a title", hint: "This is a hint?"),
                TextFieldModel(title: "You can write?"),
                TextFieldModel(title: "This is a title", placeholder: "<name>"),
                TextFieldModel(title: "<name>")
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
        
        (cell as? Marginable)?.setupCustomMargins(all: .small)
        
        return cell
    }
    
    // MARK: - Additional Helpers
}
