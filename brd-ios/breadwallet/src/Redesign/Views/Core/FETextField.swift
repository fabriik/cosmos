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
import SnapKit

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
    
    var autocapitalizationType: UITextAutocapitalizationType = .sentences
    var autocorrectionType: UITextAutocorrectionType = .default
    var keyboardType: UIKeyboardType = .default
}

struct TextFieldModel: ViewModel {
    var leading: ImageViewModel?
    var title: String?
    var value: String?
    var placeholder: String?
    var hint: String?
    var error: String?
    var info: InfoViewModel? //= InfoViewModel(description: .text("Please enter ur name."))
    var trailing: ImageViewModel?
    var validator: ((String?) -> Bool)? = { text in return (text?.count ?? 0) >= 1 }
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    
    var displayState: DisplayState = .normal
    
    private var validator: ((String?) -> Bool)?
    var contentSizeChanged: (() -> Void)?
    var valueChanged: ((String?) -> Void)?
    
    override var isUserInteractionEnabled: Bool {
        get {
            return textField.isUserInteractionEnabled
        }
        
        set {
            content.isUserInteractionEnabled = newValue
            textField.isUserInteractionEnabled = newValue
        }
    }
    
    var isPicker = false
    
    var value: String? {
        get { return textField.text }
        set {
            textField.text = newValue
            animateTo(state: newValue?.isEmpty == true ? .error : .filled)
        }
    }
    
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
        view.isHidden = true
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
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(textFieldContent)
        mainStack.addArrangedSubview(hintLabel)
        
        textFieldContent.addSubview(textFieldStack)
        textFieldStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(Margins.large.rawValue)
            make.top.equalTo(Margins.medium.rawValue)
        }
        textFieldStack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        textFieldContent.addSubview(trailingView)
        trailingView.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.trailing.equalTo(-Margins.large.rawValue)
            make.top.equalTo(Margins.small.rawValue)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        textFieldStack.addArrangedSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        textField.delegate = self
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapped)
    }
    
    @objc func tapped() {
        let state: DisplayState = textField.isFirstResponder ? .disabled : .selected
        animateTo(state: state, withAnimation: true)
        textField.becomeFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var background: BackgroundConfiguration?
        switch displayState {
        case .normal, .filled:
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
        textField.autocapitalizationType = config.autocapitalizationType
        textField.autocorrectionType = config.autocorrectionType
        textField.keyboardType = config.keyboardType
        
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
        
        validator = viewModel.validator
        titleLabel.setup(with: .text(viewModel.title))
        titleLabel.isHidden = viewModel.title == nil
        textField.text = viewModel.value
        
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
        
        titleStack.isHidden = leadingView.isHidden && trailingView.isHidden && titleLabel.isHidden
        
        layoutSubviews()
        
        guard textField.text?.isEmpty == false else {
            return
        }
        animateTo(state: .filled, withAnimation: false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateTo(state: .selected)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTo(state: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField.text)//?.lowercased())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isValid = validator?(textField.text) == true
        let state: DisplayState = isValid ? .filled : .error
        animateTo(state: state, withAnimation: true)
        
        return isValid
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        var state = state
        
        if validator?(textField.text) != true,
           textField.text?.isEmpty != true {
            state = .error
        }
        var hint = viewModel?.hint
        var hideTextField = textField.text?.isEmpty == true
        var hideTitleStack = false
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            
        case .filled:
            background = config?.backgroundConfiguration
            hideTextField = false
            
            hideTitleStack = isPicker
            
        case .highlighted, .selected:
            background = config?.selectedBackgroundConfiguration
            hideTextField = false
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
            hideTextField = false
            hint = viewModel?.error
        }
        
        titleStack.isHidden = hideTitleStack
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
        
        Self.animate(withDuration: Presets.Animation.duration, animations: {
            self.textFieldContent.layoutIfNeeded()
        }, completion: { _ in
            self.contentSizeChanged?()
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
