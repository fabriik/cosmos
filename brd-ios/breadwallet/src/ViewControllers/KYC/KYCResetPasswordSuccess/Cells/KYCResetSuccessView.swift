// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCResetSuccessView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {}
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
        titleLabel.text = "PASSWORD RECOVERY"
        
        return titleLabel
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "KYC Green Tick Success")
        
        return iconImageView
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .gray3
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Password recovery was successful. Use your new password to log in."
        
        return subtitleLabel
    }()
    
    private lazy var nextButton: SimpleButton = {
        let nextButton = SimpleButton()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setup(as: .kycEnabled, title: "LOGIN")
        
        return nextButton
    }()
    
    var didTapLoginButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        let defaultDistance: CGFloat = 12
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: defaultDistance * 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        addSubview(iconImageView)
        iconImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: defaultDistance * 4).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 68).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(subtitleLabel)
        subtitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: defaultDistance * 3).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 40).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -40).isActive = true
        
        addSubview(nextButton)
        nextButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: defaultDistance * 3).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        nextButton.didTap = { [weak self] in
            self?.didTapLoginButton?()
        }
    }
    
    func setup(with model: ViewModel) {}
}
