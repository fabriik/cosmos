// 
//  ImageView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct ImageViewConfiguration: BackgorundConfigurable {
    var backgroundColor: UIColor = .clear
    var tintColor: UIColor
}

enum ImageViewModel: ViewModel {
    case animation(String)
    case image(String)
}

class FEImageView: FEView<ImageViewConfiguration, ImageViewModel> {
    
    // MARK: Lazy UI
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - View setup
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(imageView)
        let constraints = [
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: NCViewProtocol
    override func configure(with config: ImageViewConfiguration?) {
        super.configure(with: config)
        guard let tintColor = config?.tintColor else { return }
        imageView.tintColor = tintColor
    }
    
    // MARK: ViewModelable
    public override func setup(with viewModel: ImageViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        switch viewModel {
        case .image(let image):
            imageView.image = .init(named: image)
            
        default:
            return
        }
        
        setupSubviews()
        configure(with: config)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
