//
//  KYCDocumentPickerViewController.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import AVFoundation
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
    
    var confirmPhoto: (() -> Void)?
    
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
                view.configure(with: .init(image: Presets.Image.primary,
                                           label: .init(font: Fonts.Title.six,
                                                        textColor: LightColors.Contrast.one),
                                           shadow: Presets.Shadow.normal,
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
            interactor?.selectDocument(viewAction: .init(index: indexPath.row))
            
        default: return
        }
    }

    // MARK: - User Interaction

    // MARK: - KYCDocumentPickerResponseDisplay
    
    func displayTakePhoto(responseDisplay: KYCDocumentPickerModels.Photo.ResponseDisplay) {
        LoadingView.hide()
        
        coordinator?.showImagePicker(model: responseDisplay.model,
                                     device: responseDisplay.device) { [weak self] image in
            guard let image = image else { return }
            self?.coordinator?.showDocumentReview(checklist: responseDisplay.checklist, image: image)
        }
    }
    
    func displayFinish(responseDisplay: KYCDocumentPickerModels.Finish.ResponseDisplay) {
        LoadingView.hide()
        
        coordinator?.showKYCFinal()
    }
    
    // MARK: - Additional Helpers
}

protocol ImagePickable: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(model: KYCCameraImagePickerModel?,
                         device: AVCaptureDevice,
                         completion: ((UIImage?) -> Void)?)
}
