//
//  SwapMainViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import AVFoundation
import UIKit

class SwapMainViewController: BaseTableViewController<KYCCoordinator,
                              SwapMainInteractor,
                              SwapMainPresenter,
                              SwapMainStore>,
                              SwapMainResponseDisplays {
    
    typealias Models = SwapMainModels
    
    override var sceneLeftAlignedTitle: String? {
         // TODO: localize
        return "Swap"
    }
    
    // TODO: Get rid of those if possible.
    private var fromFiatAmount: SwapMainModels.Amounts.CurrencyData?
    private var fromCryptoAmount: SwapMainModels.Amounts.CurrencyData?
    private var toFiatAmount: SwapMainModels.Amounts.CurrencyData?
    private var toCryptoAmount: SwapMainModels.Amounts.CurrencyData?
    
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
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.Shadow.light,
                                       background: .init(backgroundColor: LightColors.Background.three,
                                                         tintColor: LightColors.Text.one,
                                                         border: Presets.Border.zero)))
            view.setup(with: .init(fromFiatAmount: "", fromCryptoAmount: "", toFiatAmount: "", toCryptoAmount: ""))
            
            view.didChangeFromFiatAmount = { [weak self] amount in
                self?.fromFiatAmount = amount
                self?.handleData()
            }
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.fromCryptoAmount = amount
                self?.handleData()
            }
            
            view.didChangeToFiatAmount = { [weak self] amount in
                self?.toFiatAmount = amount
                self?.handleData()
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.toCryptoAmount = amount
                self?.handleData()
            }
        }
        
        return cell
    }
    
    private func handleData() {
        interactor?.setAmount(viewAction: .init(fromFiatAmount: fromFiatAmount,
                                                fromCryptoAmount: fromCryptoAmount,
                                                toFiatAmount: toFiatAmount,
                                                toCryptoAmount: toCryptoAmount))
    }
    
    override func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard var model = sectionRows[section]?[indexPath.row] as? ButtonViewModel,
              let cell: WrapperTableViewCell<FEButton> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.Button.primary)
            view.setup(with: model)
            view.setupCustomMargins(vertical: .large, horizontal: .large)
            
            // TODO: Handle with configs
            view.isEnabled = false
            
            view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            self.handleData()
        }
        
        return cell
    }
    
    // MARK: - User Interaction

    @objc override func buttonTapped() {
        super.buttonTapped()
        
        // TODO: Confirm logic
    }
    
    // MARK: - SwapMainResponseDisplay
    
    func displaySetAmount(responseDisplay: SwapMainModels.Amounts.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Sections.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.shouldEnableConfirm
    }
    
    // MARK: - Additional Helpers
}
