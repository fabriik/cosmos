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
    var leadingImageConfiguration: BackgroundConfiguration?
    var titleConfiguration: LabelConfiguration?
    var textConfiguration: LabelConfiguration?
    var placeholderConfiguration: LabelConfiguration?
    var hintConfiguration: LabelConfiguration?
    var trailingImageConfiguration: BackgroundConfiguration?
    
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
    var error: String?
    var info: InfoViewModel? //= InfoViewModel(description: .text("Please enter ur name."))
    var trailing: ImageViewModel?
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    
    var displayState: DisplayState = .normal
    
    var validator: ((String?) -> Bool)? = { text in return (text?.count ?? 0) > 1 }
    var valueChanged: (() -> Void)?
    
    // MARK: Lazy UI
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var textFieldContent: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var hintLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var leadingView: FEImageView = {
        let view = FEImageView()
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.isHidden = true
        return view
    }()
    
    private lazy var trailingView: FEImageView = {
        let view = FEImageView()
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(textFieldContent)
        textFieldContent.snp.makeConstraints { make in
            make.height.equalTo(58)
        }
        mainStack.addArrangedSubview(hintLabel)
        
        textFieldContent.addSubview(textFieldStack)
        textFieldStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(Margins.large.rawValue)
            make.top.equalTo(Margins.small.rawValue)
        }
        textFieldStack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(trailingView)
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        textFieldStack.addArrangedSubview(textField)
        
        textField.delegate = self
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapped)
    }
    
    @objc func tapped() {
        let state: DisplayState = textField.isFirstResponder ? .disabled : .selected
        animateTo(state: state, withAnimation: true)
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

        if let placeholder = viewModel.placeholder,
           let config = config?.placeholderConfiguration {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: (config.textColor ?? .black),
                .font: config.font
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        if let hint = viewModel.hint {
            hintLabel.setup(with: .text(hint))
        }
        hintLabel.isHidden = viewModel.hint == nil

        leadingView.isHidden = viewModel.leading == nil
        leadingView.setup(with: viewModel.leading)

        trailingView.isHidden = viewModel.trailing == nil
        trailingView.setup(with: viewModel.trailing)
        layoutSubviews()
    }

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
        titleLabel.isHidden = false
        leadingView.isHidden = false
        trailingView.isHidden = false
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        
        var hint = viewModel?.hint
        var hideTextField = textField.text?.isEmpty == true
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            
        case .highlighted, .selected:
            background = config?.selectedBackgroundConfiguration
            hideTextField = false
            textField.becomeFirstResponder()
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
            hideTextField = false
            hint = "ERROR ERROR"
        }
        textField.isHidden = hideTextField
        hintLabel.isHidden = hint == nil
        
        if let text = hint,
           !text.isEmpty {
            hintLabel.setup(with: .text(text))
        }
        
        displayState = state
        
        hintLabel.configure(with: .init(textColor: background?.tintColor))
        // Border
        configure(background: background)
        // Shadow
        configure(shadow: config?.shadowConfiguration)
        
        valueChanged?()
        
        Self.animate(withDuration: 0.25, animations: {
            self.textFieldContent.layoutIfNeeded()
        }, completion: { _ in
            self.valueChanged?()
        })
    }
    
    override func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        let content = textFieldContent
        
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
        let content = textFieldContent
        
        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
    }
}
