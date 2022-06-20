// 
//  CodeInputView.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CodeInputConfiguration: Configurable {
    var normal: BackgroundConfiguration? = Presets.Background.Primary.normal
    var selected: BackgroundConfiguration? = Presets.Background.Primary.selected
    var error: BackgroundConfiguration? = Presets.Background.Primary.error
    var input: TextFieldConfiguration = .init(textConfiguration: .init(font: Fonts.Subtitle.one,
                                                                       textColor: LightColors.Text.one,
                                                                       textAlignment: .center,
                                                                       numberOfLines: 1))
    var errorLabel: LabelConfiguration = .init(font: Fonts.caption, textColor: LightColors.error)
}

struct CodeInputViewModel: ViewModel {}

class CodeInputView: FEView<CodeInputConfiguration, CodeInputViewModel>, StateDisplayable {
    
    var numberOfFields: Int { return 6 }
    
    var contentSizeChanged: (() -> Void)?
    var valueChanged: ((String?) -> Void)?
    var displayState: DisplayState = .normal
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var inputStack: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var inputTextfields: [FETextField] = {
        var views = [FETextField]()
        for _ in (0..<numberOfFields) {
            let view = FETextField()
            view.isUserInteractionEnabled = false
            views.append(view)
        }
        return views
    }()
    
    private lazy var errorLabel: FELabel = {
        let view = FELabel()
        view.text = "Invalid code"
        view.isHidden = true
        return view
    }()
    
    private lazy var hiddenTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .numberPad
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(hiddenTextField)
        hiddenTextField.alpha = 0
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        stack.addArrangedSubview(inputStack)
        inputStack.snp.makeConstraints { make in
            // TODO: constant
            make.height.equalTo(FieldHeights.common.rawValue)
        }
        
        for view in inputTextfields {
            inputStack.addArrangedSubview(view)
        }
        stack.addArrangedSubview(errorLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func configure(with config: CodeInputConfiguration?) {
        super.configure(with: config)
        configure(background: config?.normal)
        
        inputTextfields.forEach { field in
            field.configure(with: config?.input)
        }
        
        errorLabel.configure(with: config?.errorLabel)
    }

    override func setup(with viewModel: CodeInputViewModel?) {
        super.setup(with: viewModel)
    }
    
    @objc private func tapped() {
        hiddenTextField.becomeFirstResponder()
        animateTo(state: .selected)
    }
    
    @objc func keyboardWillHide() {
        animateTo(state: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField.text)
        
        guard let text = textField.text,
        text.count <= numberOfFields else {
            if let text = textField.text?.prefix(numberOfFields) {
                textField.text = String(text)
            }
            errorLabel.text = "Entered code is too long. Should be \(numberOfFields) characters"
            return animateTo(state: .error)
        }
        
        animateTo(state: .selected)
        let textArray = Array(text)
        for (index, field) in inputTextfields.enumerated() {
            var value: String?
            if textArray.count > index {
                value = String(textArray[index])
            }
            
            field.setup(with: .init(value: value))
        }
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        guard let config = config,
              displayState != state
        else { return }
        let background: BackgroundConfiguration?
        switch state {
        case .selected:
            background = config.selected
            
        case .error:
            background = config.error
            
        default:
            background = config.normal
        }
        errorLabel.isHidden = state != .error
        displayState = state
        configure(background: background)
        
        Self.animate(withDuration: Presets.Animation.duration) { [weak self] in
            self?.layoutIfNeeded()
            self?.contentSizeChanged?()
        }
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let border = background?.border else { return }
        
        inputTextfields.forEach { textField in
            textField.layer.masksToBounds = true
            textField.layer.cornerRadius = border.cornerRadius.rawValue
            textField.layer.borderWidth = border.borderWidth
            textField.layer.borderColor = border.tintColor.cgColor
        }
    }
}
