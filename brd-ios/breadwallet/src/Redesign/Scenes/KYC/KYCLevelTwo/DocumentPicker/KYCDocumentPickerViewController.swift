//
//  KYCDocumentPickerViewController.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

class KYCDocumentPickerViewController: BaseTableViewController<KYCCoordinator,
                                       KYCDocumentPickerInteractor,
                                       KYCDocumentPickerPresenter,
                                       KYCDocumentPickerStore>,
                                       KYCDocumentPickerResponseDisplays {
    
    typealias Models = KYCDocumentPickerModels
    
    override var sceneTitle: String? {
         // TODO: localize
        return "Proof of Identity"
    }

    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .title:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            cell.setupCustomMargins(vertical: .large, horizontal: .small)
            
        case .documents:
            cell = self.tableView(tableView, navigationCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<NavigationItemView>)?.setup({ view in
                view.configure(with: .init(shadow: Presets.Shadow.normal,
                                           background: .init(backgroundColor: LightColors.Background.three,
                                                             tintColor: LightColors.Text.one,
                                                             border: Presets.Border.zero)))
                view.setupClearMargins()
            })
            cell.setupClearMargins()
            
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] as? Models.Sections {
        case .documents:
            interactor?.verify(viewAction: .init(index: indexPath.row))
            
        default: return
        }
    }

    // MARK: - User Interaction

    // MARK: - KYCDocumentPickerResponseDisplay
    func displayVerify(responseDisplay: KYCDocumentPickerModels.Documents.ResponseDisplay) {
        coordinator?.showDocumentVerification(for: responseDisplay.document)
    }
    
    // MARK: - Additional Helpers
}
