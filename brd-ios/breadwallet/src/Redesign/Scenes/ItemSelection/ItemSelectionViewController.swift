//
//  ItemSelectionViewController.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionViewController: BaseTableViewController<ItemSelectionCoordinator,
                                   ItemSelectionInteractor,
                                   ItemSelectionPresenter,
                                   ItemSelectionStore>,
                                   ItemSelectionResponseDisplays {
    
    typealias Models = ItemSelectionModels
    var itemSelected: ((String) -> Void)?

    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.register(WrapperTableViewCell<ItemView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? String
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.setup(with: .init(title: model, imageName: model))
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        guard let code = sectionRows[section]?[indexPath.row] as? String else { return }
        itemSelected?(code)
        coordinator?.goBack()
    }
    // MARK: - User Interaction

    // MARK: - ItemSelectionResponseDisplay

    // MARK: - Additional Helpers
}
