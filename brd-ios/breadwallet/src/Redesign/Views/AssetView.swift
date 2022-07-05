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

struct AssetConfiguration: Configurable {
    var topConfiguration = LabelConfiguration(font: Fonts.Title.six, textColor: LightColors.Text.one)
    var bottomConfiguration = LabelConfiguration(font: Fonts.Subtitle.two, textColor: LightColors.Text.two)
}

struct AssetViewModel: ViewModel {
    var icon: ImageViewModel = .imageName("BTC")
    var name: String
    var code: String
    var amount: Double?
    var exchangeRate: Double?
    var fiatCurrency = "$"
}

class AssetView: FEView<AssetConfiguration, AssetViewModel> {
    
    private lazy var iconView: FEImageView = {
        let view = FEImageView()
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
    
    private lazy var assetValueLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var fiatValueLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(iconView)
        content.setupCustomMargins(all: .large)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leadingMargin)
            make.height.equalTo(40)
            make.width.equalTo(iconView.snp.height)
            make.centerY.equalToSuperview()
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
        
        valueStack.addArrangedSubview(assetValueLabel)
        valueStack.addArrangedSubview(fiatValueLabel)
    }
    
    override func configure(with config: AssetConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        titleLabel.configure(with: config.topConfiguration)
        assetValueLabel.configure(with: config.topConfiguration)
        
        subtitleLabel.configure(with: config.bottomConfiguration)
        fiatValueLabel.configure(with: config.bottomConfiguration)
    }
    
    override func setup(with viewModel: AssetViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        if let image = TokenImageSquareBackground(code: viewModel.code, color: .red).renderedImage {
            iconView.setup(with: .image(image))
        }
        
        titleLabel.setup(with: .text(viewModel.name))
        subtitleLabel.setup(with: .text(viewModel.code))
        
        guard let amount = viewModel.amount,
              let exchangeRate = viewModel.exchangeRate else {
            valueStack.isHidden = true
            return
        }
        valueStack.isHidden = false
        assetValueLabel.setup(with: .text("\(amount) \(viewModel.code)"))
        // TODO: currency formater (sometimes the
        fiatValueLabel.setup(with: .text("\(viewModel.fiatCurrency) \(amount * exchangeRate)"))
    }
}
