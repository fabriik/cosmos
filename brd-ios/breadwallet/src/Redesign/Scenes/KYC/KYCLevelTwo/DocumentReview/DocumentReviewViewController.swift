//
//  DocumentReviewViewController.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//
//

import UIKit

class DocumentReviewViewController: BaseTableViewController<KYCCoordinator,
                                    DocumentReviewInteractor,
                                    DocumentReviewPresenter,
                                    DocumentReviewStore>,
                                    DocumentReviewResponseDisplays {
    
    typealias Models = DocumentReviewModels

    override var sceneTitle: String? {
         // TODO: localize
        return "Submit your photo"
    }
    
    var retakePhoto: (() -> Void)?
    var confirmPhoto: (() -> Void)?
    
    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .title:
            cell =  self.tableView(tableView, labelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Title.six, textColor: LightColors.Text.one))
            
        case .checkmarks:
            cell = self.tableView(tableView, checkmarCellForRowAt: indexPath)
            
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .buttons:
            cell = self.tableView(tableView, buttonsCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        cell.setupCustomMargins(vertical: .huge, horizontal: .medium)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, buttonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<ScrollableButtonsView> else {
            return cell
        }
        
        cell.wrappedView.configure(with: .init(buttons: [Presets.Button.primary]))
        
        cell.wrappedView.callbacks = [
            retakePhotoTapped,
            confirmPhotoTapped
        ]
        
        return cell
    }

    // MARK: - User Interaction

    private func retakePhotoTapped() {
        retakePhoto?()
    }
    
    private func confirmPhotoTapped() {
        confirmPhoto?()
    }
    
    // MARK: - DocumentReviewResponseDisplay

    // MARK: - Additional Helpers
}
