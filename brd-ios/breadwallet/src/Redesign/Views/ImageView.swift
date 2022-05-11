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

class ImageView: BaseView<ImageViewConfiguration, ImageViewModel> {
    
    // MARK: Lazy UI
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - View setup
    override func setupSubviews() {
        super.setupSubviews()

        let accessoryView: UIView
        switch viewModel {
        case .image:
            accessoryView = imageView

        default:
            return
        }

        setupClearMargins()
    }
    
    // MARK: NCViewProtocol
    override func configure(with config: ImageViewConfiguration?) {
        super.configure(with: config)
        guard let tintColor = config?.tintColor else { return }
        
        switch viewModel {
        case .image:
            imageView.tintColor = tintColor
            
        default:
            return
        }
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
        switch viewModel {
        case .image:
            imageView.image = nil
            imageView.removeFromSuperview()

        default:
            return
        }

        super.prepareForReuse()
    }
}
