// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SimpleTextField: UIView, UITextFieldDelegate {
    enum FieldType {
        case text, numbers, password, email, picker
    }
    
    enum TextFieldStyle {
        case tfEnabled
        case tfDisabled
        
        var tintColor: UIColor? {
            switch self {
            case .tfEnabled:
                return .kycGray1
                
            case .tfDisabled:
                return .kycGray3
                
            }
        }
    }
    
    private var fieldType: FieldType = .text
    private var fieldStyle: TextFieldStyle?
    
    private lazy var rightButton: UIButton = {
        let rightButton = UIButton()
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.isUserInteractionEnabled = false
        
        return rightButton
    }()
    
    private lazy var showHidePasswordButton: UIButton = {
        let showHidePasswordButton = UIButton()
        showHidePasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showHidePasswordButton.setImage(UIImage(named: "KYC ShowPassword"), for: .normal)
        showHidePasswordButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        showHidePasswordButton.isHidden = true
        
        return showHidePasswordButton
    }()
    
    private lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .kycGray2
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        
        return titleLabel
    }()
    
    lazy var textField: PaddedTextField = {
        var textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .kycGray1
        textField.clipsToBounds = true
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 4
        textField.layer.borderColor = UIColor.kycGray1.cgColor
        textField.layer.borderWidth = 1
        
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        var errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .kycRed
        errorLabel.font = UIFont(name: "AvenirNext-Regular", size: 11)
        errorLabel.text = "Cannot be empty"
        errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 1
        errorLabel.isHidden = true
        
        return errorLabel
    }()
    
    var didChangeText: ((String?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setup(as fieldType: FieldType, title: String, customPlaceholder: String? = nil) {
        self.fieldType = fieldType
        
        textField.delegate = self
        
        let font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        textField.font = font
        textField.attributedPlaceholder = NSAttributedString(string: customPlaceholder ?? "",
                                                             attributes: [.foregroundColor: UIColor.kycGray2, .font: font])
        
        titleLabel.text = title
        
        switch fieldType {
        case .text:
            textField.keyboardType = .default
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .no
            
        case .numbers:
            textField.keyboardType = .numberPad
            
        case .picker:
            rightButton.setImage(UIImage(named: "KYC Dropdown Arrow"), for: .normal)
            rightButton.tintColor = .kycGray1
            textField.inputView = UIView()
            textField.inputAccessoryView = UIView()
            
        case .email:
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            
        case .password:
            textField.isSecureTextEntry = true
            showHidePasswordButton.isHidden = false
            textField.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 48)
        }
        
        setupElements()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch fieldType {
        case .numbers:
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let isOnlyNumbersAllowed = allowedCharacters.isSuperset(of: characterSet)
            
            return isOnlyNumbersAllowed
            
        default:
            return true
        }
    }
    
    func setupFieldStyle(with textFieldStyle: TextFieldStyle) {
        self.fieldStyle = textFieldStyle
        
        style()
    }
    
    private func style() {
        textField.layer.borderColor = fieldStyle?.tintColor?.cgColor
        rightButton.tintColor = fieldStyle?.tintColor
        
        switch fieldStyle {
        case .tfEnabled, .none:
            textField.isUserInteractionEnabled = true
       
        case .tfDisabled:
            textField.isUserInteractionEnabled = false
            textField.text = nil
            errorLabel.isHidden = true
            
        }
    }
    
    private func setupElements() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        addSubview(textField)
        textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(errorLabel)
        errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        textField.addSubview(rightButton)
        rightButton.topAnchor.constraint(equalTo: textField.topAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -8).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        rightButton.heightAnchor.constraint(equalTo: textField.heightAnchor).isActive = true
        
        textField.addSubview(showHidePasswordButton)
        showHidePasswordButton.topAnchor.constraint(equalTo: textField.topAnchor).isActive = true
        showHidePasswordButton.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        showHidePasswordButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -8).isActive = true
        showHidePasswordButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        showHidePasswordButton.heightAnchor.constraint(equalTo: textField.heightAnchor).isActive = true
    }
    
    func setCheckMark(isVisible: Bool) {
        rightButton.isHidden = !isVisible
        rightButton.setImage(isVisible ? UIImage(named: "Field Check Mark") : nil, for: .normal)
        
        if isVisible {
            textField.layer.borderColor = UIColor.kycGreen.cgColor
            
            if fieldType == .password {
                showHidePasswordButton.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -6).isActive = true
            }
        }
    }
    
    func setEmptyErrorMessage(isFieldEmpty: Bool) {
        errorLabel.text = "Cannot be empty"
        errorLabel.textColor = UIColor.kycRed
        errorLabel.isHidden = !isFieldEmpty
        textField.layer.borderColor = isFieldEmpty ? UIColor.kycRed.cgColor : UIColor.kycGray1.cgColor
    }
    
    func setDescriptionMessage(isWrongFormat: Bool) {
        errorLabel.text = fieldType == .email ? "Wrong email format" : "Weak password"
        errorLabel.textColor = UIColor.kycGray1
        errorLabel.isHidden = !isWrongFormat
        textField.layer.borderColor = isWrongFormat ? UIColor.kycRed.cgColor : UIColor.kycGray1.cgColor
    }
    
    @objc func togglePasswordView(_ sender: Any) {
        showHidePasswordButton.isSelected.toggle()
        textField.isSecureTextEntry = !showHidePasswordButton.isSelected
        textField.setPasswordToggleImage(showHidePasswordButton)
    }
    
    func roundSpecifiedCorners(maskedCorners: CACornerMask) {
        textField.layer.maskedCorners = maskedCorners
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch fieldType {
        case .picker:
            endEditing(true)
            resignFirstResponder()
            
        default:
            break
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch fieldType {
        case .picker:
            return false
            
        default:
            return true
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        didChangeText?(textField.text)
    }
}
