// 
//  TransparentView.swift
//  breadwallet
//
//  Created by Rok on 03/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

struct TransparentViewConfiguration: Configurable {
    var background = BackgroundConfiguration(backgroundColor: LightColors.Contrast.two.withAlphaComponent(0.8),
                                             tintColor: LightColors.success)
    var title: LabelConfiguration?
}

enum TransparentViewModel: ViewModel {
    case success
    case loading
    
    var imageName: String? {
        switch self {
        case .success:
            return "check"
            
        default:
            return nil
        }
    }
    
    var duration: Double {
        switch self {
        case .success:
            return 2.0
            
        default:
            return 0.0
        }
    }
    
    var title: String? { return nil }
}

class TransparentView: FEView<TransparentViewConfiguration, TransparentViewModel> {
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var imageView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        stack.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(imageView.snp.height)
            // TODO: constant
            make.height.equalTo(79)
        }
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            // TODO: constant
            make.height.equalTo(20)
        }
    }
    
    override func configure(with config: TransparentViewConfiguration?) {
        super.configure(with: config)
        
        backgroundColor = config?.background.backgroundColor
        imageView.configure(with: .init(tintColor: config?.background.tintColor))
        titleLabel.configure(with: config?.title)
    }
    
    override func setup(with viewModel: TransparentViewModel?) {
        super.setup(with: viewModel)
        
        if let image = viewModel?.imageName {
            imageView.setup(with: .imageName(image))
        }
        imageView.isHidden = viewModel?.imageName == nil
        
        titleLabel.setup(with: .text(viewModel?.title))
        titleLabel.isHidden = viewModel?.title == nil
    }
    
    func show() {
        alpha = 0
        Self.animate(withDuration: Presets.Animation.duration) { [weak self] in
            self?.alpha = 1
        }
        
        // autodismiss
        guard let delay = viewModel?.duration else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        Self.animate(withDuration: Presets.Animation.duration, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
        })
    }
}
