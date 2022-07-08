// 
//  AssetView.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Presets {
    struct Asset {
        static var Header = AssetConfiguration(topConfiguration: .init(font: Fonts.Title.six, textColor: LightColors.Text.one),
                                               bottomConfiguration: .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.two),
                                               backgroundConfiguration: .init(backgroundColor: LightColors.tertiary,
                                                                              tintColor: LightColors.Text.one,
                                                                              border: Presets.Border.zero),
                                               imageConfig: .init(backgroundColor: LightColors.pending, tintColor: .white, border: .init(borderWidth: 0, cornerRadius: .medium)),
                                               imageSize: .small)
    }
}

struct AssetConfiguration: Configurable {
    var topConfiguration = LabelConfiguration(font: Fonts.Title.six, textColor: LightColors.Text.one)
    var bottomConfiguration = LabelConfiguration(font: Fonts.Subtitle.two, textColor: LightColors.Text.two)
    var topRightConfiguration = LabelConfiguration(font: Fonts.Title.six, textColor: LightColors.Text.one, textAlignment: .right)
    var bottomRightConfiguration = LabelConfiguration(font: Fonts.Subtitle.two, textColor: LightColors.Text.two, textAlignment: .right)
    var backgroundConfiguration: BackgroundConfiguration?
    var imageConfig: BackgroundConfiguration?
    var imageSize: ViewSizes = .medium
}

struct AssetViewModel: ViewModel {
    var icon: ImageViewModel = .imageName("swap")
    var title: String?
    var subtitle: String?
    var topRightText: String?
    var bottomRightText: String?
}

class AssetView: FEView<AssetConfiguration, AssetViewModel> {
    
    private lazy var iconView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var subtitleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var valueStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var topRightLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var bottomRightLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(iconView)
        content.setupCustomMargins(all: .large)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leadingMargin)
            make.top.equalTo(content.snp.topMargin).priority(.low)
            make.centerY.equalToSuperview()
            
            make.height.equalTo(ViewSizes.medium.rawValue)
            make.width.equalTo(ViewSizes.medium.rawValue)
        }
        
        content.addSubview(titleStack)
        titleStack.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Margins.small.rawValue)
            make.centerY.equalToSuperview()
            make.top.equalTo(content.snp.topMargin)
        }
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subtitleLabel)
        
        content.addSubview(valueStack)
        valueStack.snp.makeConstraints { make in
            make.trailing.equalTo(content.snp.trailingMargin)
            make.centerY.equalToSuperview()
            make.top.equalTo(content.snp.topMargin)
        }
        
        valueStack.addArrangedSubview(topRightLabel)
        valueStack.addArrangedSubview(bottomRightLabel)
    }
    
    override func configure(with config: AssetConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        titleLabel.configure(with: config.topConfiguration)
        topRightLabel.configure(with: config.topRightConfiguration)
        
        subtitleLabel.configure(with: config.bottomConfiguration)
        bottomRightLabel.configure(with: config.bottomRightConfiguration)
        
        iconView.snp.updateConstraints { make in
            make.height.equalTo(config.imageSize.rawValue)
            make.width.equalTo(config.imageSize.rawValue)
        }
        
        iconView.content.setupCustomMargins(all: config.imageConfig == nil ? .zero : .extraSmall)
        
        iconView.configure(background: config.imageConfig)
        configure(background: config.backgroundConfiguration)
    }
    
    override func setup(with viewModel: AssetViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        iconView.wrappedView.setup(with: viewModel.icon)
        
        titleLabel.setup(with: .text(viewModel.title))
        titleLabel.isHidden = viewModel.title == nil
        
        subtitleLabel.setup(with: .text(viewModel.subtitle))
        subtitleLabel.isHidden = viewModel.subtitle == nil
        
        topRightLabel.setup(with: .text(viewModel.topRightText))
        topRightLabel.isHidden = viewModel.topRightText == nil
        
        bottomRightLabel.setup(with: .text(viewModel.bottomRightText))
        bottomRightLabel.isHidden = viewModel.bottomRightText == nil
    }
}
