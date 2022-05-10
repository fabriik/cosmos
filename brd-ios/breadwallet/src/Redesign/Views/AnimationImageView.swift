// 
//  AnimationImageView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BackgorundConfiguration: BackgorundConfigurable {
    var backgroundColor: UIColor
    var tintColor: UIColor
}

struct ShadowConfiguration: ShadowConfigurable {
    var color: UIColor
    var opacity: Opacity
    var offset: CGSize
    var cornerRadius: CornerRadius
}

struct BorderConfiguration: BorderConfigurable {
    var tintColor: UIColor
    var borderWidth: CGFloat
    var cornerRadius: CornerRadius
}

struct ImageViewConfiguration: Configurable, ImageViewConfigurable {
    var backgroundConfiguration: BackgorundConfiguration
    var shadowConfiguration: ShadowConfiguration?
    var borderConfiguration: BorderConfiguration?
}

enum ImageViewModel: ViewModel {
    case animation(String)
    case image(String)
}

class ImageView: BaseView<ImageViewConfiguration, ImageViewModel> {
    // MARK: Lazy UI
    
    // TODO: lottie or no lottie?
    private lazy var animationView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
//        view.backgroundBehavior = .pauseAndRestore
//        view.loopMode = .loop
        
        return view
    }()
    
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
//        case .animation:
//            accessoryView = animationView

        case .image:
            accessoryView = imageView

        default:
            return
        }

        content.addSubview(accessoryView)
//        accessoryView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }

        setupClearMargins()
    }
    
    // MARK: NCViewProtocol
    override func configure(with config: ImageViewConfiguration?) {
        super.configure(with: config)
        guard let tintColor = config?.backgroundConfiguration.tintColor else { return }
        
        switch viewModel {
//        case .animation:
//            animationView.setValueProvider(ColorValueProvider(tintColor.lottieColorValue),
//                                           keypath: AnimationKeypath(keypath: "**.Color"))
//            animationView.reloadImages()
//            animationView.forceDisplayUpdate()
            
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
//        case .animation(let animation):
//            animationView.animation = animation.animation
//            animationView.play()
            
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
//        case .animation:
//            animationView.animation = nil
//            animationView.removeFromSuperview()

        case .image:
            imageView.image = nil
            imageView.removeFromSuperview()

        default:
            return
        }

        super.prepareForReuse()
    }
}
