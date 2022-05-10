// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCPersonalInfoView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let date: String?
        let taxIdNumber: String?
    }
    
    private lazy var dateOfBirthField: SimpleTextField = {
        let dateOfBirthField = SimpleTextField()
        dateOfBirthField.translatesAutoresizingMaskIntoConstraints = false
        dateOfBirthField.setup(as: .picker, title: "DATE OF BIRTH", customPlaceholder: "DD/MM/YYYY")
        dateOfBirthField.textField.addTarget(self, action: #selector(showDateOfBirthPicker(_:)),
                                             for: .touchDown)
        
        return dateOfBirthField
    }()
    
    private lazy var taxIdNumberField: SimpleTextField = {
        let taxIdNumberField = SimpleTextField()
        taxIdNumberField.translatesAutoresizingMaskIntoConstraints = false
        taxIdNumberField.setup(as: .numbers, title: "TAX ID NUMBER", customPlaceholder: "SSN, ITIN, or EIN")
        
        return taxIdNumberField
    }()
    
    private lazy var nextButton: SimpleButton = {
        let nextButton = SimpleButton()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setup(as: .kycDisabled, title: "NEXT")
        
        return nextButton
    }()
    
    private lazy var privacyPolicyTextView: UITextView = {
        let privacyPolicyTextView = UITextView()
        privacyPolicyTextView.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyTextView.textAlignment = .center
        privacyPolicyTextView.textColor = .gray2
        privacyPolicyTextView.font = UIFont(name: "AvenirNext-Regular", size: 14)
        privacyPolicyTextView.isEditable = false
        privacyPolicyTextView.tintColor = .gray2
        
        return privacyPolicyTextView
    }()
    
    var didTapDateOfBirthField: (() -> Void)?
    var didChangeTaxIdNumberField: ((String?) -> Void)?
    var didTapNextButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let defaultDistance: CGFloat = 12
        
        addSubview(dateOfBirthField)
        dateOfBirthField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dateOfBirthField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        dateOfBirthField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        dateOfBirthField.heightAnchor.constraint(equalToConstant: 82).isActive = true
        
        addSubview(taxIdNumberField)
        taxIdNumberField.topAnchor.constraint(equalTo: dateOfBirthField.bottomAnchor, constant: defaultDistance).isActive = true
        taxIdNumberField.leadingAnchor.constraint(equalTo: dateOfBirthField.leadingAnchor).isActive = true
        taxIdNumberField.trailingAnchor.constraint(equalTo: dateOfBirthField.trailingAnchor).isActive = true
        taxIdNumberField.heightAnchor.constraint(equalTo: dateOfBirthField.heightAnchor).isActive = true
        
        addSubview(nextButton)
        nextButton.topAnchor.constraint(equalTo: taxIdNumberField.bottomAnchor, constant: defaultDistance * 2).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: dateOfBirthField.leadingAnchor).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: dateOfBirthField.trailingAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(privacyPolicyTextView)
        setupPrivacyPolicyText()
        privacyPolicyTextView.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: defaultDistance).isActive = true
        privacyPolicyTextView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        privacyPolicyTextView.leadingAnchor.constraint(equalTo: dateOfBirthField.leadingAnchor).isActive = true
        privacyPolicyTextView.trailingAnchor.constraint(equalTo: dateOfBirthField.trailingAnchor).isActive = true
        privacyPolicyTextView.heightAnchor.constraint(equalTo: nextButton.heightAnchor).isActive = true
        
        taxIdNumberField.didChangeText = { [weak self] text in
            self?.didChangeTaxIdNumberField?(text)
        }
        
        nextButton.didTap = { [weak self] in
            self?.didTapNextButton?()
        }
    }
    
    @objc private func showDateOfBirthPicker(_ textField: SimpleTextField) {
        didTapDateOfBirthField?()
    }
    
    private func setupPrivacyPolicyText() {
        let string = "Fabriik terms of use and privacy policy."
        let fullRange = (string as NSString).range(of: string)
        let termsRange = (string as NSString).range(of: "terms of use")
        let privacyRange = (string as NSString).range(of: "privacy policy")
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        var attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: style])
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray2, range: fullRange)
        
        createLink(attributedString: &attributedString, urlString: C.termsAndConditions, range: termsRange)
        createLink(attributedString: &attributedString, urlString: C.privacyPolicy, range: privacyRange)
        
        privacyPolicyTextView.attributedText = attributedString
    }
    
    private func createLink(attributedString: inout NSMutableAttributedString, urlString: String, range: NSRange) {
        guard let url = NSURL(string: urlString) else { return }
        
        attributedString.addAttribute(.link, value: url, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSNumber(value: 1), range: range)
        attributedString.addAttribute(.underlineColor, value: UIColor.gray2, range: range)
    }
    
    func setup(with model: Model) {
        if let date = model.date {
            dateOfBirthField.textField.text = date
        }
        
        if let taxIdNumber = model.taxIdNumber {
            taxIdNumberField.textField.text = taxIdNumber
        }
    }
    
    func changeFieldStyle(isFieldEmpty: Bool, for fieldType: KYCPersonalInfo.FieldType) {
        switch fieldType {
        case .date:
            dateOfBirthField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
            
        case .taxIdNumber:
            taxIdNumberField.setEmptyErrorMessage(isFieldEmpty: isFieldEmpty)
        }
    }
    
    func changeButtonStyle(with style: SimpleButton.ButtonStyle) {
        nextButton.changeStyle(with: style)
    }
}
