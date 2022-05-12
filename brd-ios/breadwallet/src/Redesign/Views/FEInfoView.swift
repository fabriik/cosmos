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
    var headerLeadingImage: ImageViewConfiguration?
    var headerTitle: LabelConfiguration?
    var headerTrailingImage: ImageViewConfiguration?
    
    var title: LabelConfiguration?
    var description: LabelConfiguration?
    var button: ButtonConfiguration?
    
    var background: BackgroundConfiguration?
    
    var border: BorderConfiguration?
    var shadow: ShadowConfiguration?
}

struct InfoViewModel: ViewModel {
    var headerLeadingImage: ImageViewModel?
    var headerTitle: LabelViewModel?
    var headerTrailingImage: ImageViewModel?
    
    var title: LabelViewModel?
    var description: LabelViewModel?
    var button: ButtonViewModel?
}

class FEInfoView: FEView<InfoViewConfiguration, InfoViewModel> {
    
    // MARK: Lazy UI
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Margins.small.rawValue
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        
        return stack
    }()
    
    private lazy var headerLeadingView: FEImageView = {
        let view = FEImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var headerTitleLabel: FELabel = {
        let label = FELabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var headerTrailingView: FEImageView = {
        let view = FEImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let label = FELabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let label = FELabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trailingButton: FEButton = {
        let view = FEButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        var constraints: [NSLayoutConstraint] = []
        
        content.addSubview(verticalStackView)
        constraints.append(contentsOf: [
            verticalStackView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: Margins.large.rawValue),
            verticalStackView.topAnchor.constraint(equalTo: content.topAnchor, constant: Margins.large.rawValue)
        ])
        
        verticalStackView.addArrangedSubview(headerStackView)
        constraints.append(headerStackView.heightAnchor.constraint(equalToConstant: Margins.huge.rawValue).priority(.defaultHigh))
        
        headerStackView.addArrangedSubview(headerLeadingView)
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerStackView.addArrangedSubview(headerTrailingView)
        constraints.append(contentsOf: [
            headerLeadingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue),
            headerTitleLabel.widthAnchor.constraint(equalTo: headerStackView.widthAnchor).priority(.defaultLow),
            headerTrailingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue)
        ])
        
        verticalStackView.addArrangedSubview(titleLabel)
        constraints.append(contentsOf: [
            titleLabel.heightAnchor.constraint(equalToConstant: Margins.large.rawValue),
            titleLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).priority(.defaultLow)
        ])

        verticalStackView.addArrangedSubview(descriptionLabel)
        constraints.append(contentsOf: [
            descriptionLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).priority(.defaultLow)
        ])

        verticalStackView.addArrangedSubview(trailingButton)
        constraints.append(trailingButton.heightAnchor.constraint(equalToConstant: Margins.extraHuge.rawValue))
        NSLayoutConstraint.activate(constraints)
    }
    
    override func configure(with config: InfoViewConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        backgroundColor = config.background?.backgroundColor
        headerLeadingView.configure(with: config.headerLeadingImage)
        headerTitleLabel.configure(with: config.headerTitle)
        headerTrailingView.configure(with: config.headerTrailingImage)
        titleLabel.configure(with: config.title)
        descriptionLabel.configure(with: config.description)
        trailingButton.configure(with: config.button)
        configure(shadow: config.shadow)
        configure(border: config.border)
    }
    
    override func setup(with viewModel: InfoViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        headerLeadingView.setup(with: viewModel.headerLeadingImage)
        headerLeadingView.isHidden = viewModel.headerLeadingImage == nil
        
        headerTitleLabel.setup(with: viewModel.headerTitle)
        headerTitleLabel.isHidden = viewModel.headerTitle == nil
        
        headerTrailingView.setup(with: viewModel.headerTrailingImage)
        headerTrailingView.isHidden = viewModel.headerTrailingImage == nil
        
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
}
