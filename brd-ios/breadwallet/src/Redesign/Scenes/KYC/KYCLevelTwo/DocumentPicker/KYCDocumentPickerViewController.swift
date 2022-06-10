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
    
    private var imagePicker: UIImagePickerController!
    
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
            toggleBlur(animated: false)
            interactor?.selectDocument(viewAction: .init(index: indexPath.row))
            
        default: return
        }
    }

    // MARK: - User Interaction

    // MARK: - KYCDocumentPickerResponseDisplay
    
    func displayTakePhoto(responseDisplay: KYCDocumentPickerModels.Photo.ResponseDisplay) {
        coordinator?.showImagePicker(sourceType: .camera,
                                     model: responseDisplay.model,
                                     device: responseDisplay.device) { [weak self] image in
            self?.interactor?.confirmPhoto(viewAction: .init(photo: image))
        }
    }
    
    func displayFinish(responseDisplay: KYCDocumentPickerModels.Finish.ResponseDisplay) {
        coordinator?.showOverlay(with: .success, completion: { [weak self] in
            self?.coordinator?.goBack()
        })
    }
    
    // MARK: - Additional Helpers
}

protocol ImagePickable: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType,
                         model: FEImagePickerModel?,
                         device: UIImagePickerController.CameraDevice,
                         completion: ((UIImage?) -> Void)?)
}
