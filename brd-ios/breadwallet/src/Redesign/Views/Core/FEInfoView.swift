// 
//  FEInfoView.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct InfoViewConfiguration: Configurable {
    var headerLeadingImage: BackgroundConfiguration?
    var headerTitle: LabelConfiguration?
    var headerTrailing: ButtonConfiguration?
    
    var title: LabelConfiguration?
    var description: LabelConfiguration?
    var button: ButtonConfiguration?
    
    var background: BackgroundConfiguration?
    var shadow: ShadowConfiguration?
}

struct InfoViewModel: ViewModel {
    var headerLeadingImage: ImageViewModel?
    var headerTitle: LabelViewModel?
    var headerTrailing: ButtonViewModel?
    
    var title: LabelViewModel?
    var description: LabelViewModel?
    var button: ButtonViewModel?
}

class FEInfoView: FEView<InfoViewConfiguration, InfoViewModel> {
    
    // MARK: public properties
    var headerButtonCallback: (() -> Void)?
    // MARK: Lazy UI
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.small.rawValue
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        
        return stack
    }()
    
    private lazy var headerLeadingView: FEImageView = {
        let view = FEImageView()
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var headerTitleLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var headerTrailingView: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var trailingButton: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
        return view
    }()
    
    // MARK: Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        verticalStackView.addArrangedSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(Margins.huge.rawValue)
        }
        
        headerStackView.addArrangedSubview(headerLeadingView)
        headerLeadingView.snp.makeConstraints { make in
            make.width.equalTo(Margins.huge.rawValue)
        }
        
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerTitleLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().priority(.low)
        }
        
        headerStackView.addArrangedSubview(headerTrailingView)
        headerTrailingView.snp.makeConstraints { make in
            make.width.equalTo(Margins.huge.rawValue)
        }
        
        verticalStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.large.rawValue)
        }

        verticalStackView.addArrangedSubview(descriptionLabel)

        verticalStackView.addArrangedSubview(trailingButton)
        trailingButton.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraHuge.rawValue)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func configure(with config: InfoViewConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        backgroundColor = config.background?.backgroundColor
        headerLeadingView.configure(with: config.headerLeadingImage)
        headerTitleLabel.configure(with: config.headerTitle)
        headerTrailingView.configure(with: config.headerTrailing)
        titleLabel.configure(with: config.title)
        descriptionLabel.configure(with: config.description)
        trailingButton.configure(with: config.button)
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func configure(background: BackgroundConfiguration?) {
        super.configure(background: background)
        guard let border = background?.border else { return }
        let content = self
        
        let radius = border.cornerRadius == .fullRadius ? content.bounds.width / 2 : border.cornerRadius.rawValue
        content.layer.cornerRadius = radius
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
        
        content.layer.masksToBounds = false
        content.layer.shadowColor = UIColor.clear.cgColor
        content.layer.shadowOpacity = 0
        content.layer.shadowOffset = .zero
        content.layer.shadowRadius = 0
        content.layer.shadowPath = UIBezierPath(roundedRect: content.bounds, cornerRadius: radius).cgPath
        content.layer.shouldRasterize = true
        content.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func setup(with viewModel: InfoViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        headerLeadingView.setup(with: viewModel.headerLeadingImage)
        headerLeadingView.isHidden = viewModel.headerLeadingImage == nil
        
        headerTitleLabel.setup(with: viewModel.headerTitle)
        headerTitleLabel.isHidden = viewModel.headerTitle == nil
        
        headerTrailingView.setup(with: viewModel.headerTrailing)
        headerTrailingView.isHidden = viewModel.headerTrailing == nil
        
        titleLabel.setup(with: viewModel.title)
        titleLabel.isHidden = viewModel.title == nil
        
        descriptionLabel.setup(with: viewModel.description)
        descriptionLabel.isHidden = viewModel.description == nil
        
        trailingButton.setup(with: viewModel.button)
        trailingButton.isHidden = viewModel.button == nil
        
        guard headerLeadingView.isHidden,
              headerTitleLabel.isHidden,
              headerTrailingView.isHidden else {
            return
        }
        headerStackView.isHidden = true
    }
    
    @objc private func trailingButtonTapped(_ sender: UIButton?) {
        headerButtonCallback?()
    }
}
