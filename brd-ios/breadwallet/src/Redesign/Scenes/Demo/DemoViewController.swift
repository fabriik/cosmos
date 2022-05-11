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
            Models.Section.label,
            Models.Section.button,
            Models.Section.textField,
            Models.Section.infoView
        ]
        
        sectionRows = [
            Models.Section.button: [
                "Click me!!",
                "Dont Click me please!!"
            ],
            
            Models.Section.textField: [
                TextFieldModel(title: "This is a title", placeholder: "<name>", hint: "You can write?"),
                TextFieldModel(placeholder: "<name>", hint: "You can write?"),
                TextFieldModel(title: "This is a title", placeholder: "<name>"),
                TextFieldModel(placeholder: "<name>")
            ],
            
            Models.Section.infoView: [
                InfoViewModel(headerTitle: .text("Kaj tu pise?"),
                              title: .text("Kak lep dan"),
                              description: .text("za ujeti svoje sanje! sanje ne bezijo marvec zivijo!"),
                              button: .init(title: "Zapri")),
                
                InfoViewModel(title: .text("Kak lep dan"),
                              description: .text("za ujeti svoje sanje! sanje ne bezijo marvec zivijo!"),
                              button: .init(title: "Zapri")),
                
                InfoViewModel(title: .text("Kak lep dan"),
                              description: .text("za ujeti svoje sanje! sanje ne bezijo marvec zivijo!"))
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
        
        (cell as? Marginable)?.setupCustomMargins(all: .extraHuge)
        cell.layoutIfNeeded()
        
        return cell
    }

    // MARK: - Additional Helpers
}
