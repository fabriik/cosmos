//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SwapCryptoView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    // TODO: Move fonts to constants
    // TODO: Cleanup labels
    
    struct ViewModel: Hashable {
        let image: UIImage?
        let title: String
        let subtitle: String
        let amount: String
        let conversion: String
    }
    
    private lazy var currencyImageView: UIImageView = {
        let currencyImageView = UIImageView()
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        currencyImageView.contentMode = .scaleAspectFit
        currencyImageView.backgroundColor = .systemPink
        currencyImageView.layer.cornerRadius = 6
        currencyImageView.layer.masksToBounds = true
        currencyImageView.clipsToBounds = true
        
        return currencyImageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .gray3
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        
        return subtitleLabel
    }()
    
    private lazy var balanceStackView: UIStackView = {
        let balanceStackView = UIStackView()
        balanceStackView.translatesAutoresizingMaskIntoConstraints = false
        balanceStackView.axis = .vertical
        balanceStackView.distribution = .fillEqually
        
        return balanceStackView
    }()
    
    private lazy var fiatLabel: UILabel = {
        let fiatLabel = UILabel()
        fiatLabel.translatesAutoresizingMaskIntoConstraints = false
        fiatLabel.textAlignment = .right
        fiatLabel.textColor = .almostBlack
        fiatLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        fiatLabel.numberOfLines = 0
        
        return fiatLabel
    }()
    
    private lazy var conversionLabel: UILabel = {
        let conversionLabel = UILabel()
        conversionLabel.translatesAutoresizingMaskIntoConstraints = false
        conversionLabel.textAlignment = .right
        conversionLabel.textColor = .gray3
        conversionLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
        conversionLabel.numberOfLines = 0
        
        return conversionLabel
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        backgroundColor = Theme.primaryBackground
        
        addBorders(edges: [.bottom],
                   color: .gray3)
        
        addSubview(currencyImageView)
        currencyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        currencyImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        currencyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        currencyImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        currencyImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: currencyImageView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 8).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        
        addSubview(subtitleLabel)
        subtitleLabel.bottomAnchor.constraint(equalTo: currencyImageView.bottomAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        
        addSubview(balanceStackView)
        balanceStackView.topAnchor.constraint(equalTo: currencyImageView.topAnchor).isActive = true
        balanceStackView.bottomAnchor.constraint(equalTo: currencyImageView.bottomAnchor).isActive = true
        balanceStackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8).isActive = true
        balanceStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        
        balanceStackView.addArrangedSubview(fiatLabel)
        balanceStackView.addArrangedSubview(conversionLabel)
    }
    
    func setup(with model: ViewModel) {
        currencyImageView.image = model.image
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        
        fiatLabel.isHidden = model.amount.isEmpty
        
        fiatLabel.text = model.amount
        conversionLabel.text = model.conversion
    }
}
