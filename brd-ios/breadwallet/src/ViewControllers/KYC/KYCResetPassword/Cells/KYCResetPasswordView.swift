//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCResetPasswordView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let code: String?
        let password: String?
        let passwordRepeat: String?
    }
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray1
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        descriptionLabel.text = "An email containing a 6-digit code has been sent to your email. Please copy it from the email and paste it below, then setup a new password."
        
        return descriptionLabel
    }()
    
    private lazy var codeField: SimpleTextField = {
        let codeField = SimpleTextField()
        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.setup(as: .numbers, title: "RECOVERY CODE", customPlaceholder: "000-000")
        codeField.textField.textContentType = .oneTimeCode
        
        return codeField
    }()
    
    private lazy var passwordField: SimpleTextField = {
        let passwordField = SimpleTextField()
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.setup(as: .password, title: "NEW PASSWORD", customPlaceholder: "Minimum 8 characters")
        
        return passwordField
    }()
    
    private lazy var passwordRepeatField: SimpleTextField = {
        let passwordRepeatField = SimpleTextField()
        passwordRepeatField.translatesAutoresizingMaskIntoConstraints = false
        passwordRepeatField.setup(as: .password, title: "CONFIRM NEW PASSWORD", customPlaceholder: "Minimum 8 characters")
        
        return passwordRepeatField
    }()
    
    private lazy var confirmButton: SimpleButton = {
        let confirmButton = SimpleButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setup(as: .kycDisabled, title: "CONFIRM")
        
        return confirmButton
    }()
    
    var didChangeCodeField: ((String?) -> Void)?
    var didChangePasswordField: ((String?) -> Void)?
    var didChangePasswordRepeatField: ((String?) -> Void)?
    var didTapConfirmButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let defaultDistance: CGFloat = 12
        
        addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        addSubview(codeField)
        codeField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: defaultDistance * 3).isActive = true
        codeField.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        codeField.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true
        codeField.heightAnchor.constraint(equalToConstant: 82).isActive = true
        
        addSubview(passwordField)
        passwordField.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: defaultDistance).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: codeField.leadingAnchor).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: codeField.trailingAnchor).isActive = true
        passwordField.heightAnchor.constraint(equalTo: codeField.heightAnchor).isActive = true
        
        addSubview(passwordRepeatField)
        passwordRepeatField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: defaultDistance).isActive = true
        passwordRepeatField.leadingAnchor.constraint(equalTo: codeField.leadingAnchor).isActive = true
        passwordRepeatField.trailingAnchor.constraint(equalTo: codeField.trailingAnchor).isActive = true
        passwordRepeatField.heightAnchor.constraint(equalTo: codeField.heightAnchor).isActive = true
        
        addSubview(confirmButton)
        confirmButton.topAnchor.constraint(equalTo: passwordRepeatField.bottomAnchor, constant: defaultDistance * 3).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: codeField.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: codeField.trailingAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        codeField.didChangeText = { [weak self] text in
            self?.didChangeCodeField?(text)
        }
        
        passwordField.didChangeText = { [weak self] text in
            self?.didChangePasswordField?(text)
        }
        
        passwordRepeatField.didChangeText = { [weak self] text in
            self?.didChangePasswordRepeatField?(text)
        }
        
        confirmButton.didTap = { [weak self] in
            self?.didTapConfirmButton?()
        }
    }
    
    func setup(with model: ViewModel) {
        codeField.textField.text = model.code
        passwordField.textField.text = model.password
        passwordRepeatField.textField.text = model.passwordRepeat
    }
    
    func changeButtonStyle(with style: SimpleButton.ButtonStyle) {
        confirmButton.changeStyle(with: style)
    }
    
    func changeFieldStyle(isViable: Bool, isFieldEmpty: Bool, for fieldType: KYCResetPassword.FieldType) {
        let isWrongFormat = !isViable && !isFieldEmpty
        
        switch fieldType {
        case .recoveryCode:
            codeField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
            codeField.setCheckMark(isVisible: isViable)
            
        case .password:
            passwordField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
            passwordField.setCheckMark(isVisible: isViable)
            if isWrongFormat {
                passwordField.setDescriptionMessage(isWrongFormat: isWrongFormat)
            }
            
        case .passwordRepeat:
            passwordRepeatField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
            passwordRepeatField.setCheckMark(isVisible: isViable)
            if isWrongFormat {
                passwordRepeatField.setDescriptionMessage(isWrongFormat: isWrongFormat)
            }
        }
    }
}
