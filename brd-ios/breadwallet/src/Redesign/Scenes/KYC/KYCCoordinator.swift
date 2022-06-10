// 
//  KYCCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class KYCCoordinator: BaseCoordinator, KYCBasicRoutes, KYCDocumentPickerRoutes {
    
    override func start() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showCountrySelector(selected: ((String?) -> Void)?) {
        let nvc = UINavigationController()
        let coordinator = ItemSelectionCoordinator(navigationController: nvc)
        coordinator.start()
        coordinator.parentCoordinator = self
        (nvc.topViewController as? ItemSelectionViewController)?.itemSelected = selected
        childCoordinators.append(coordinator)
        navigationController.show(nvc, sender: nil)
    }
    
    func showKYCLevelOne() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showKYCLevelTwo() {
        open(scene: Scenes.KYCLevelTwo)
    }
    
    func showIdentitySelector() {
        open(scene: Scenes.KYCDocumentPicker)
    }
    
    func showDocumentVerification(for document: Document) {
        showUnderConstruction("\(document.title) verification")
    }
    
    func showLevelTwoValidation() {
        open(scene: Scenes.KYCLevelTwoPostValidation)
    }
    
    override func goBack() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
}

extension KYCCoordinator: ImagePickable {
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType = .camera,
                         model: FEImagePickerModel?,
                         completion: ((UIImage?) -> Void)?) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let controller = FEImagePickerController()
        controller.sourceType = sourceType
        controller.configure(with: .init(instructions: .init(font: Fonts.Body.one,
                                                             textColor: LightInversedColors.Text.one,
                                                             textAlignment: .center),
                                         background: .init(backgroundColor: LightInversedColors.Background.one)))
        controller.setup(with: model)
        controller.photoSelected = completion
        navigationController.present(controller, animated: true)
    }
}

struct FEImagePickerConfiguration: Configurable {
    var instructions: LabelConfiguration?
    var background: BackgroundConfiguration?
}

struct FEImagePickerModel: ViewModel {
    var instruction: LabelViewModel?
    var confirmation: LabelViewModel?
}

class FEImagePickerController: UIImagePickerController, ViewProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var config: FEImagePickerConfiguration?
    var viewModel: FEImagePickerModel?
    
    var photoSelected: ((UIImage?) -> Void)?
    
    private lazy var instructionsLabel: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        delegate = self
        view.addSubview(instructionsLabel)
        instructionsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(Margins.extraHuge.rawValue)
            // TODO: constant or pin to smth else?
            make.bottom.equalToSuperview().inset(212)
        }
        
        instructionsLabel.setupCustomMargins(all: .small)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"),
                                               object: nil, queue: nil, using: { [weak self] _ in
            self?.instructionsLabel.wrappedView.setup(with: self?.viewModel?.confirmation)
            self?.instructionsLabel.isHidden = self?.viewModel?.confirmation == nil
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"),
                                               object: nil, queue: nil, using: { [weak self] _ in
            self?.instructionsLabel.wrappedView.setup(with: self?.viewModel?.instruction)
            self?.instructionsLabel.isHidden = self?.viewModel?.instruction == nil
        })
    }
    
    func configure(with config: FEImagePickerConfiguration?) {
        self.config = config
        instructionsLabel.wrappedView.configure(with: config?.instructions)
        instructionsLabel.backgroundColor = config?.background?.backgroundColor
    }
    
    func setup(with viewModel: FEImagePickerModel?) {
        self.viewModel = viewModel
        
        instructionsLabel.wrappedView.setup(with: viewModel?.instruction)
        instructionsLabel.isHidden = viewModel?.instruction == nil
        instructionsLabel.layoutIfNeeded()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        photoSelected?(image)
    }
}
