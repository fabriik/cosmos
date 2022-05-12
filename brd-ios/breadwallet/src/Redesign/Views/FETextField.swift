// 
//  FETextField.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TextFieldConfiguration: Configurable {
    var leadingImageConfiguration: ImageViewConfiguration?
    var titleConfiguration: LabelConfiguration?
    var textConfiguration: LabelConfiguration?
    var placeholderConfiguration: LabelConfiguration?
    var hintConfiguration: LabelConfiguration?
    var trailingImageConfiguration: ImageViewConfiguration?
    
    var backgroundConfiguration: BackgroundConfiguration?
    var selectedBackgroundConfiguration: BackgroundConfiguration?
    var disabledBackgroundConfiguration: BackgroundConfiguration?
    var errorBackgroundConfiguration: BackgroundConfiguration?
    
    var shadowConfiguration: ShadowConfiguration?
    var borderConfiguration: BorderConfiguration?
}

struct TextFieldModel: ViewModel {
    var leading: ImageViewModel?
    var title: String?
    var placeholder: String?
    var hint: String?
    var trailing: ImageViewModel?
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    
    // MARK: Lazy UI
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        
        return stack
    }()
    
    private lazy var titleLabel: FELabel = {
        let label = FELabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var hintLabel: FELabel = {
        let label = FELabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var leadingView: FEImageView = {
        let view = FEImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var textField: UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trailingView: FEImageView = {
        let view = FEImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        var constraints: [NSLayoutConstraint] = []
        
        content.addSubview(verticalStackView)
        constraints.append(contentsOf: [
            verticalStackView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: content.topAnchor)
        ])
        
        verticalStackView.addArrangedSubview(titleLabel)
        constraints.append(contentsOf: [
            titleLabel.heightAnchor.constraint(equalToConstant: Margins.large.rawValue),
            titleLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).priority(.defaultLow)
        ])

        verticalStackView.addArrangedSubview(horizontalStackView)
        constraints.append(horizontalStackView.heightAnchor.constraint(equalToConstant: Margins.huge.rawValue).priority(.defaultHigh))

        verticalStackView.addArrangedSubview(hintLabel)
        constraints.append(contentsOf: [
            hintLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).priority(.defaultLow),
            hintLabel.heightAnchor.constraint(equalToConstant: Margins.large.rawValue)
        ])

        horizontalStackView.addArrangedSubview(leadingView)
        constraints.append(leadingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue))

        horizontalStackView.addArrangedSubview(textField)
        constraints.append(textField.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor).priority(.defaultLow))

        horizontalStackView.addArrangedSubview(trailingView)
        constraints.append(trailingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue))
        
        NSLayoutConstraint.activate(constraints)
        
        textField.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var background: BackgroundConfiguration?
        if textField.isFirstResponder,
            let bgColor = backgroundColor, let tint = tintColor {
            background = .init(backgroundColor: bgColor, tintColor: tint)
        }
        // Border
        configure(border: config?.borderConfiguration, backgroundConfiguration: background)
        // Shadow
        configure(shadow: config?.shadowConfiguration)
    }
    
    override func configure(with config: TextFieldConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        titleLabel.configure(with: config.titleConfiguration)
        hintLabel.configure(with: config.hintConfiguration)
        
        if let textConfig = config.textConfiguration {
            textField.font = textConfig.font
            textField.textColor = textConfig.textColor
            textField.textAlignment = textConfig.textAlignment
            textField.tintColor = config.backgroundConfiguration?.tintColor
        }
        
        leadingView.configure(with: config.leadingImageConfiguration)
        trailingView.configure(with: config.trailingImageConfiguration)
    }
    
    public override func setup(with viewModel: TextFieldModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)

        if let text = viewModel.title {
            titleLabel.setup(with: .text(text))
        }
        titleLabel.isHidden = viewModel.title == nil

        if let text = viewModel.hint {
            hintLabel.setup(with: .text(text))
        }
        hintLabel.isHidden = viewModel.hint == nil

        if let placeholder = viewModel.placeholder {
            let config = Presets.Label.secondary
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: config.textColor,
                .font: config.font
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }

        leadingView.isHidden = viewModel.leading == nil
        leadingView.setup(with: viewModel.leading)

        trailingView.isHidden = viewModel.trailing == nil
        trailingView.setup(with: viewModel.trailing)
    }
    
    func displayError(message: String? = nil) {
        let hideHint = message == nil
        // TODO: constant
        UIView.animate(withDuration: 0.25) { [unowned self] in
            let tintColor: UIColor?
            if let message = message {
                hintLabel.setup(with: .text(message))
                tintColor = config?.errorBackgroundConfiguration?.tintColor
            } else {
                tintColor = config?.backgroundConfiguration?.tintColor
            }

            hintLabel.isHidden = hideHint
            leadingView.tintColor = tintColor
            textField.textColor = hideHint ? config?.textConfiguration?.textColor : tintColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateTo(state: .selected)
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTo(state: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingView.prepareForReuse()
        trailingView.prepareForReuse()
        
        textField.text = nil
        textField.placeholder = nil
        hintLabel.text = nil
        titleLabel.text = nil
        
        textField.isHidden = false
        textField.isHidden = false
        hintLabel.isHidden = false
        titleLabel.isHidden = false
        leadingView.isHidden = false
        trailingView.isHidden = false
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        
        let background: BackgroundConfiguration?
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            
            // TODO: any need to split?
        case .highlighted, .selected:
            background = config?.selectedBackgroundConfiguration
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
        }
        
        // TODO: constant for duration
        UIView.animate(withDuration: withAnimation ? 0.25 : 0) { [weak self] in
            self?.backgroundColor = background?.backgroundColor
            self?.tintColor = background?.tintColor
            self?.setNeedsLayout()
        }
    }
}
