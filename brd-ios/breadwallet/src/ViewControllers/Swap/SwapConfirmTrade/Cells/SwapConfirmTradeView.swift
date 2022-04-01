//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SwapConfirmTradeView: BaseView, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {}
    
    private lazy var currencyStack: UIStackView = {
        let tradeStack = UIStackView()
        tradeStack.translatesAutoresizingMaskIntoConstraints = false
        tradeStack.backgroundColor = .clear
        tradeStack.axis = .horizontal
        tradeStack.spacing = 4
        
        return tradeStack
    }()
    
    private lazy var tradeStack: UIStackView = {
        let tradeStack = UIStackView()
        tradeStack.translatesAutoresizingMaskIntoConstraints = false
        tradeStack.backgroundColor = .clear
        tradeStack.axis = .vertical
        tradeStack.spacing = 4
        
        return tradeStack
    }()
    
    private lazy var tradeLabel: UILabel = {
        let tradeLabel = UILabel()
        tradeLabel.translatesAutoresizingMaskIntoConstraints = false
        tradeLabel.textAlignment = .center
        tradeLabel.textColor = .kycLightGray
        tradeLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        tradeLabel.text = "Trade"
        
        return tradeLabel
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(named: "KYC Header Logo")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 8
        iconImageView.backgroundColor = .clear
        
        return iconImageView
    }()
    
    private lazy var currencyLabel: UILabel = {
        let currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.textAlignment = .center
        currencyLabel.textColor = .white
        currencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        currencyLabel.text = "0.0799 ETH"
        
        return currencyLabel
    }()
    
    private lazy var label: UILabel = {
        let currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.textAlignment = .center
        currencyLabel.textColor = .white
        currencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 30)
        currencyLabel.text = ">"
        
        return currencyLabel
    }()
    
    private lazy var tradeForStack: UIStackView = {
        let tradeStack = UIStackView()
        tradeStack.translatesAutoresizingMaskIntoConstraints = false
        tradeStack.backgroundColor = .clear
        tradeStack.axis = .vertical
        tradeStack.spacing = 4
        
        return tradeStack
    }()
    
    private lazy var tradeForLabel: UILabel = {
        let tradeLabel = UILabel()
        tradeLabel.translatesAutoresizingMaskIntoConstraints = false
        tradeLabel.textAlignment = .center
        tradeLabel.textColor = .kycLightGray
        tradeLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        tradeLabel.text = "For"
        
        return tradeLabel
    }()
    
    private lazy var tradeForImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(named: "LogoBlue")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 8
        iconImageView.backgroundColor = .clear
        
        return iconImageView
    }()
    
    private lazy var tradeForCurrencyLabel: UILabel = {
        let currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.textAlignment = .center
        currencyLabel.textColor = .white
        currencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        currencyLabel.text = "86.4012 BRD"
        
        return currencyLabel
    }()

    override func setupSubviews() {
        super.setupSubviews()
        
        backgroundColor = .clear
        let defaultDistance: CGFloat = 50
        
        addSubview(currencyStack)
        currencyStack.topAnchor.constraint(equalTo: topAnchor, constant: defaultDistance).isActive = true
        currencyStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: defaultDistance).isActive = true
        currencyStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -defaultDistance).isActive = true
        
        currencyStack.addArrangedSubview(tradeStack)
        tradeStack.addArrangedSubview(tradeLabel)
        tradeStack.addArrangedSubview(iconImageView)
        tradeStack.addArrangedSubview(currencyLabel)
        
        currencyStack.addArrangedSubview(label)
        currencyStack.addArrangedSubview(tradeForStack)
        
        tradeForStack.addArrangedSubview(tradeForLabel)
        tradeForStack.addArrangedSubview(tradeForImageView)
        tradeForStack.addArrangedSubview(tradeForCurrencyLabel)
    }
    
    func setup(with model: ViewModel) {
    }
}
