//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCConfirmEmailView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let confirmationCode: String?
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
        titleLabel.text = "CONFIRMATION CODE"
        
        return titleLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray1
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        descriptionLabel.text = "We’ve sent a SMS with a confirmation code to your mobile phone. Please enter the 6-digit code below."
        
        return descriptionLabel
    }()
    
    private lazy var confirmationCodeField: SimpleTextField = {
        let confirmationCodeField = SimpleTextField()
        confirmationCodeField.translatesAutoresizingMaskIntoConstraints = false
        confirmationCodeField.setup(as: .numbers, title: "CONFIRMATION CODE", customPlaceholder: "000-000")
        confirmationCodeField.textField.textContentType = .oneTimeCode
        
        return confirmationCodeField
    }()
    
    private lazy var confirmButton: SimpleButton = {
        let confirmButton = SimpleButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setup(as: .kycDisabled, title: "CONFIRM")
        
        return confirmButton
    }()
    
    private lazy var resendCodeButton: UIButton = {
        let resendCodeButton = UIButton()
        resendCodeButton.translatesAutoresizingMaskIntoConstraints = false
        resendCodeButton.addTarget(self, action: #selector(resendCodeAction), for: .touchUpInside)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray1,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributeString = NSMutableAttributedString(
            string: "Resend code",
            attributes: attributes
        )
        resendCodeButton.setAttributedTitle(attributeString, for: .normal)
        
        return resendCodeButton
    }()
    
    var didChangeConfirmationCodeField: ((String?) -> Void)?
    var didTapConfirmButton: (() -> Void)?
    var didTapResendButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let defaultDistance: CGFloat = 12
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: defaultDistance * 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        addSubview(confirmationCodeField)
        confirmationCodeField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: defaultDistance * 3).isActive = true
        confirmationCodeField.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        confirmationCodeField.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true
        confirmationCodeField.heightAnchor.constraint(equalToConstant: 82).isActive = true
        
        addSubview(confirmButton)
        confirmButton.topAnchor.constraint(equalTo: confirmationCodeField.bottomAnchor, constant: defaultDistance).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: confirmationCodeField.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: confirmationCodeField.trailingAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(resendCodeButton)
        resendCodeButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: defaultDistance * 2).isActive = true
        resendCodeButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        resendCodeButton.leadingAnchor.constraint(equalTo: confirmationCodeField.leadingAnchor).isActive = true
        resendCodeButton.trailingAnchor.constraint(equalTo: confirmationCodeField.trailingAnchor).isActive = true
        resendCodeButton.heightAnchor.constraint(equalTo: confirmButton.heightAnchor).isActive = true
        
        confirmationCodeField.didChangeText = { [weak self] text in
            self?.didChangeConfirmationCodeField?(text)
        }
        
        confirmButton.didTap = { [weak self] in
            self?.didTapConfirmButton?()
        }
    }
    
    @objc private func resendCodeAction() {
        didTapResendButton?()
    }
    
    func setup(with model: ViewModel) {
        confirmationCodeField.textField.text = model.confirmationCode
    }
    
    func changeButtonStyle(with style: SimpleButton.ButtonStyle) {
        confirmButton.changeStyle(with: style)
    }
    
    func changeFieldStyle(isViable: Bool, isFieldEmpty: Bool) {
        confirmationCodeField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
        confirmationCodeField.setCheckMark(isVisible: isViable)
    }
}
