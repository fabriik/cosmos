// 
//  OrderView.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct OrderConfiguration: Configurable {
    var title = LabelConfiguration(font: Fonts.caption, textColor: LightColors.Text.one, textAlignment: .center, numberOfLines: 1)
    var value = LabelConfiguration(font: Fonts.Body.two, textColor: LightColors.Text.one, numberOfLines: 1, lineBreakMode: .byClipping)
    var icon = BackgroundConfiguration(tintColor: LightColors.Text.one)
    var valueContent = BackgroundConfiguration(tintColor: LightColors.Text.one,
                                               border: .init(tintColor: LightColors.Text.one,
                                                             borderWidth: BorderWidth.minimum.rawValue,
                                                             cornerRadius: .fullRadius))
}

struct OrderViewModel: ViewModel {
    var title: String
    var value: String
    var imageName = "copy"
}

class OrderView: FEView<OrderConfiguration, OrderViewModel> {
    
    var copyCallback: ((String?) -> Void)?
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var bottomStack: WrapperView<UIStackView> = {
        let view = WrapperView<UIStackView>()
        return view
    }()
    
    private lazy var valueLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var imageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        return view
    }()
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure(background: config?.valueContent)
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualTo(content.snp.topMargin)
            make.leading.greaterThanOrEqualTo(content.snp.leadingMargin)
        }
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bottomStack)
        bottomStack.wrappedView.addArrangedSubview(valueLabel)
        bottomStack.wrappedView.addArrangedSubview(imageView)
        imageView.wrappedView.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.width.equalTo(14)
        }
        imageView.content.setupCustomMargins(all: .small)
        bottomStack.content.setupCustomMargins(horizontal: .small)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        content.addGestureRecognizer(tapGesture)
    }
    
    override func configure(with config: OrderConfiguration?) {
        super.configure(with: config)
        titleLabel.configure(with: config?.title)
        valueLabel.configure(with: config?.value)
        imageView.tintColor = config?.valueContent.tintColor
        configure(background: config?.valueContent)
    }
    
    override func configure(background: BackgroundConfiguration?) {
        guard let border = config?.valueContent.border else { return }
        let content = bottomStack
        
        let radius = border.cornerRadius == .fullRadius ? content.bounds.height / 2 : border.cornerRadius.rawValue
        content.layer.cornerRadius = radius
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
        
        content.layer.masksToBounds = false
        content.layer.shadowColor = UIColor.clear.cgColor
        content.layer.shadowOpacity = 0
        content.layer.shadowOffset = .zero
        content.layer.shadowRadius = 0
        content.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        content.layer.shouldRasterize = true
        content.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func setup(with viewModel: OrderViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        titleLabel.setup(with: .text(viewModel.title))
        valueLabel.setup(with: .text(viewModel.value))
        imageView.wrappedView.setup(with: .imageName(viewModel.imageName))
    }
    
    // MARK: - User interaction
    @objc private func viewTapped() {
        copyCallback?("Coppied \(viewModel?.value ?? "no_tx")!")
    }
}
