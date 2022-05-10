//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCForgotPasswordView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let email: String?
    }
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray1
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        descriptionLabel.text = "Please enter an email below that you have used to register with Fabriik Wallet."
        
        return descriptionLabel
    }()
    
    private lazy var emailField: SimpleTextField = {
        let emailField = SimpleTextField()
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.setup(as: .email, title: "EMAIL", customPlaceholder: "Email address")
        
        return emailField
    }()
    
    private lazy var confirmButton: SimpleButton = {
        let confirmButton = SimpleButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setup(as: .kycDisabled, title: "CONFIRM")
        
        return confirmButton
    }()
    
    var didChangeEmailField: ((String?) -> Void)?
    var didTapConfirmButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let defaultDistance: CGFloat = 12
        
        addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        addSubview(emailField)
        emailField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: defaultDistance * 3).isActive = true
        emailField.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        emailField.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 82).isActive = true
        
        addSubview(confirmButton)
        confirmButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: defaultDistance * 2).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        emailField.didChangeText = { [weak self] text in
            self?.didChangeEmailField?(text)
        }
        
        confirmButton.didTap = { [weak self] in
            self?.didTapConfirmButton?()
        }
    }
    
    func setup(with model: ViewModel) {
        emailField.textField.text = model.email
    }
    
    func changeButtonStyle(with style: SimpleButton.ButtonStyle) {
        confirmButton.changeStyle(with: style)
    }
    
    func changeFieldStyle(isViable: Bool, isFieldEmpty: Bool) {
        emailField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
        emailField.setCheckMark(isVisible: isViable)
        
        let isWrongFormat = !isViable && !isFieldEmpty
        if isWrongFormat {
            emailField.setDescriptionMessage(isWrongFormat: isWrongFormat)
        }
    }
}
