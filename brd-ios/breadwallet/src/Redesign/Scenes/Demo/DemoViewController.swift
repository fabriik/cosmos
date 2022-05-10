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
        
        tableView.frame = view.frame
        tableView.register(WrapperTableViewCell<UILabel>.self)
        
        sections = [Models.Section.demo]
        sectionRows = [Models.Section.demo: ["test", "rok"]]
    }
    
    // MARK: - User Interaction
    // MARK: - DemoResponseDisplay
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = sections[indexPath.section] as? Models.Section,
              let text = sectionRows[section]?[indexPath.row] as? String,
              let cell: WrapperTableViewCell<UILabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { label in
            label.text = text
            label.textAlignment = .center
        }
        
        return cell
        
    }

    // MARK: - Additional Helpers
}
