// 
//  FEDocumentPickerViewController.swift
//  breadwallet
//
//  Created by Rok on 10/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

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
