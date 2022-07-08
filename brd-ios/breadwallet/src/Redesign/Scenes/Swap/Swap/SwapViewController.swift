//
//  SwapViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapViewController: BaseTableViewController<SwapCoordinator,
                              SwapInteractor,
                              SwapPresenter,
                              SwapStore>,
                              SwapResponseDisplays {
    
    typealias Models = SwapModels
    
    override var sceneLeftAlignedTitle: String? {
         // TODO: localize
        return "Swap"
    }
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.delaysContentTouches = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
        
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FEButton>)?.wrappedView.isEnabled = false
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, swapMainCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<MainSwapView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let model = sectionRows[sections]?[indexPath.row] as? MainSwapViewModel
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.Shadow.light,
                                       background: .init(backgroundColor: LightColors.Background.three,
                                                         tintColor: LightColors.Text.one,
                                                         border: Presets.Border.zero)))
            view.setup(with: model)
            
            view.didChangeFromFiatAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fromFiatAmount: amount))
            }
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fromCryptoAmount: amount))
            }
            
            view.didChangeToFiatAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(toFiatAmount: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(toCryptoAmount: amount))
            }
            
            view.assetsSelectionCallback = { [weak self]
                in
                self?.coordinator?.openAssetSelection()
            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction

    @objc override func buttonTapped() {
        super.buttonTapped()
        
        // TODO: Confirm logic
    }
    
    // MARK: - SwapResponseDisplay
    
    func displaySetAmount(responseDisplay: SwapModels.Amounts.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Sections.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.shouldEnableConfirm
    }
    
    // MARK: - Additional Helpers
}
