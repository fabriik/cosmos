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
                                   ItemSelectionResponseDisplays,
                                   UISearchResultsUpdating,
                                   UISearchBarDelegate {
   
    typealias Models = ItemSelectionModels
    var itemSelected: ((String?) -> Void)?
    
    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.register(WrapperTableViewCell<ItemView>.self)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    @objc override func dismissModal() {
        itemSelected?(nil)
        super.dismissModal()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? CountryResponseData
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.setup(with: .init(title: model.localizedName ?? "", imageName: model.iso2 ?? ""))
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? CountryResponseData else { return }
        itemSelected?(model.iso2)
        coordinator?.goBack()
    }
    
    // MARK: - Search View Delegate
    var searchController = UISearchController()
    
    func updateSearchResults(for searchController: UISearchController) {}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            interactor?.getData(viewAction: .init())
            return
        }
        
        search(searchText)
    }
    
    func search(_ text: String) {
        interactor?.search(viewAction: .init(text: text))
    }
    
    // MARK: - User Interaction

    // MARK: - ItemSelectionResponseDisplay

    // MARK: - Additional Helpers
}
