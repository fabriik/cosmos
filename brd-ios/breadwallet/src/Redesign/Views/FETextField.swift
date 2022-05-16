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
    
    var infoConfiguration: InfoViewConfiguration? = Presets.InfoView.primary
    
    var backgroundConfiguration: BackgroundConfiguration?
    var selectedBackgroundConfiguration: BackgroundConfiguration?
    var disabledBackgroundConfiguration: BackgroundConfiguration?
    var errorBackgroundConfiguration: BackgroundConfiguration?
    
    var shadowConfiguration: ShadowConfiguration?
}

struct TextFieldModel: ViewModel {
    var leading: ImageViewModel?
    var title: String
    var placeholder: String?
    var hint: String?
    var info: InfoViewModel? //= InfoViewModel(description: .text("Please enter ur name."))
    var trailing: ImageViewModel?
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    
    var displayState: DisplayState = .normal
    
    var validator: ((String?) -> Bool)? = { text in return (text?.count ?? 0) > 1 }
    
    // MARK: Lazy UI
    private lazy var containerStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var verticalStackView: WrapperView<UIStackView> = {
        let view = WrapperView<UIStackView>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup { view in
            view.axis = .vertical
            view.spacing = Margins.zero.rawValue
            view.alignment = .fill
            view.distribution = .fill
        }
        return view
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        view.isHidden = true
        
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var hintLabel: FELabel = {
        let view = FELabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var infoView: FEInfoView = {
        let view = FEInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var leadingView: FEImageView = {
        let view = FEImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        content.addSubview(containerStack)
        constraints.append(contentsOf: [
            containerStack.leftAnchor.constraint(equalTo: content.leftAnchor, constant: Margins.small.rawValue),
            containerStack.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -Margins.small.rawValue),
            containerStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -Margins.small.rawValue),
            containerStack.topAnchor.constraint(equalTo: content.topAnchor, constant: Margins.small.rawValue)
        ])
        
        // TODO: add container for error + vertical stack (only vertical stack needs to be 'bordered')
        containerStack.addArrangedSubview(verticalStackView)
        constraints.append(verticalStackView.heightAnchor.constraint(equalToConstant: 48))
        verticalStackView.setupClearMargins()
        
        containerStack.addArrangedSubview(hintLabel)
        constraints.append(hintLabel.heightAnchor.constraint(equalToConstant: Margins.large.rawValue))
        
        verticalStackView.wrappedView.addArrangedSubview(titleLabel)
        constraints.append(titleLabel.heightAnchor.constraint(equalToConstant: Margins.large.rawValue))

        verticalStackView.wrappedView.addArrangedSubview(horizontalStackView)
        constraints.append(horizontalStackView.heightAnchor.constraint(equalToConstant: Margins.huge.rawValue).priority(.defaultHigh))

        horizontalStackView.addArrangedSubview(leadingView)
        constraints.append(leadingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue))

        horizontalStackView.addArrangedSubview(textField)
        constraints.append(textField.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor).priority(.defaultLow))

        horizontalStackView.addArrangedSubview(trailingView)
        constraints.append(trailingView.widthAnchor.constraint(equalToConstant: Margins.huge.rawValue))
        
        NSLayoutConstraint.activate(constraints)
        
        textField.delegate = self
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapped)
    }
    
    @objc private func tapped() {
        animateTo(state: .selected, withAnimation: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var background: BackgroundConfiguration?
        switch displayState {
        case .normal:
            background = config?.backgroundConfiguration
            
            // TODO: any need to split?
        case .highlighted, .selected:
            background = config?.selectedBackgroundConfiguration
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
        }
        
//        if textField.isFirstResponder {
//            background = config?.selectedBackgroundConfiguration
//        }
        // Border
        configure(background: background)
        // Shadow
        configure(shadow: config?.shadowConfiguration)
    }
    
    override func configure(with config: TextFieldConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        titleLabel.configure(with: config.titleConfiguration)
        hintLabel.configure(with: config.hintConfiguration)
        infoView.configure(with: config.infoConfiguration)
        
        if let textConfig = config.textConfiguration {
            textField.font = textConfig.font
            textField.textColor = textConfig.textColor
            textField.textAlignment = textConfig.textAlignment
            textField.tintColor = config.backgroundConfiguration?.tintColor
        }
        
        leadingView.configure(with: config.leadingImageConfiguration)
        trailingView.configure(with: config.trailingImageConfiguration)
    }
    
    override func setup(with viewModel: TextFieldModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)

        titleLabel.setup(with: .text(viewModel.title))

        if let text = viewModel.hint {
            hintLabel.setup(with: .text(text))
        }
        hintLabel.isHidden = true
        
        infoView.setup(with: viewModel.info)
        infoView.isHidden = viewModel.info == nil

        if let placeholder = viewModel.placeholder {
            let config = Presets.Label.secondary
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: (config.textColor ?? .black),
                .font: config.font
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }

        leadingView.isHidden = viewModel.leading == nil
        leadingView.setup(with: viewModel.leading)

        trailingView.isHidden = viewModel.trailing == nil
        trailingView.setup(with: viewModel.trailing)
        layoutIfNeeded()
    }
    
//    func displayError(message: String? = nil) {
//        let hideHint = message == nil
//        // TODO: constant
//        UIView.animate(withDuration: 0.25) { [unowned self] in
//            let tintColor: UIColor?
//            if let message = message {
//                hintLabel.setup(with: .text(message))
//                tintColor = config?.errorBackgroundConfiguration?.tintColor
//            } else {
//                tintColor = config?.backgroundConfiguration?.tintColor
//            }
//
//            if hideHint != hintLabel.isHidden {
//                hintLabel.isHidden = hideHint
//            }
//
//            leadingView.tintColor = tintColor
//            textField.textColor = hideHint ? config?.textConfiguration?.textColor : tintColor
//
//        }
//    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateTo(state: .selected)
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTo(state: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isValid = validator?(textField.text) == true
        if !isValid {
            hintLabel.text = "Text has to be longer than 1 character."
        }
        let state: DisplayState = isValid ? .normal : .error
        animateTo(state: state, withAnimation: true)
        
        return true
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
            horizontalStackView.isHidden = textField.text?.isEmpty == true
            textField.resignFirstResponder()
            
            // TODO: any need to split?
        case .highlighted, .selected:
            horizontalStackView.isHidden = false
            background = config?.selectedBackgroundConfiguration
            textField.becomeFirstResponder()
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
        }
        
        displayState = state
        
        // TODO: constant for duration
        UIView.animate(withDuration: withAnimation ? 0.25 : 0) { [unowned self] in
            if hintLabel.isHidden == (state == .error) {
                hintLabel.isHidden = state != .error
            }
            hintLabel.configure(with: .init(textColor: background?.tintColor))
            // Border
            configure(background: background)
            // Shadow
            configure(shadow: config?.shadowConfiguration)
            textField.layoutIfNeeded()
            titleLabel.layoutIfNeeded()
            horizontalStackView.layoutIfNeeded()
            verticalStackView.wrappedView.layoutIfNeeded()
            containerStack.layoutIfNeeded()
        }
    }
    
    override func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        let content = verticalStackView
        
        content.layer.masksToBounds = false
        content.layer.shadowColor = shadow.color.cgColor
        content.layer.shadowOpacity = shadow.opacity.rawValue
        content.layer.shadowOffset = shadow.offset
        content.layer.shadowRadius = 1
        content.layer.shadowPath = UIBezierPath(roundedRect: content.bounds, cornerRadius: shadow.cornerRadius.rawValue).cgPath
        content.layer.shouldRasterize = true
        content.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let border = background?.border else { return }
        let content = verticalStackView
        
        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
    }
}
