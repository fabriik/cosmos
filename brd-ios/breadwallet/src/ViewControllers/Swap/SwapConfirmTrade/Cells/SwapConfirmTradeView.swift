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
        tradeLabel.textColor = .almostBlack
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
        currencyLabel.textColor = .almostBlack
        currencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        currencyLabel.text = "0.0799 ETH"
        
        return currencyLabel
    }()
    
    private lazy var label: UILabel = {
        let currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.textAlignment = .center
        currencyLabel.textColor = .almostBlack
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
        tradeLabel.textColor = .almostBlack
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
        currencyLabel.textColor = .almostBlack
        currencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        currencyLabel.text = "86.4012 BRD"
        
        return currencyLabel
    }()
    
    private lazy var receiveAmountcurrencyBackgroundView: UIView = {
        let receiveAmountcurrencyBackgroundView = UIView()
        receiveAmountcurrencyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        receiveAmountcurrencyBackgroundView.backgroundColor = Theme.secondaryBackground.withAlphaComponent(0.1)
        
        return receiveAmountcurrencyBackgroundView
    }()
    
    private lazy var tradeInfoView: UIView = {
        let tradeInfoView = UIView()
        tradeInfoView.translatesAutoresizingMaskIntoConstraints = false
        tradeInfoView.backgroundColor = .clear
        
        return tradeInfoView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        titleLabel.text = "Price:"
        
        return titleLabel
    }()
    
    private lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .right
        infoLabel.textColor = .almostBlack
        infoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        infoLabel.text = "1 ETH = 1.562.589 BRD"
        
        return infoLabel
    }()
    
    private lazy var titleLabel1: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        titleLabel.text = "Delivery:"
        
        return titleLabel
    }()
    
    private lazy var infoLabel1: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .right
        infoLabel.textColor = .almostBlack
        infoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        infoLabel.text = "1-6 hours"
        
        return infoLabel
    }()
    
    private lazy var titleLabel2: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        titleLabel.text = "Fee:"
        
        return titleLabel
    }()
    
    private lazy var infoLabel2: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .right
        infoLabel.textColor = .almostBlack
        infoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        infoLabel.text = "0.0011 ETH"
        
        return infoLabel
    }()
    
    private lazy var titleLabel3: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        titleLabel.text = "Total Charge:"
        
        return titleLabel
    }()
    
    private lazy var infoLabel3: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .right
        infoLabel.textColor = .almostBlack
        infoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        infoLabel.text = "0.0799 ETH"
        
        return infoLabel
    }()

    override func setupSubviews() {
        super.setupSubviews()
        
        backgroundColor = Theme.primaryBackground
        let defaultDistance: CGFloat = 70
        
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
        
        let defaultViewsDistance: CGFloat = 16
        
        addSubview(tradeInfoView)
       tradeInfoView.topAnchor.constraint(equalTo: currencyStack.bottomAnchor, constant: 210).isActive = true
        tradeInfoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: defaultViewsDistance).isActive = true
        tradeInfoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -defaultViewsDistance).isActive = true
        tradeInfoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -defaultViewsDistance).isActive = true
        
        tradeInfoView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: tradeInfoView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(infoLabel)
        infoLabel.topAnchor.constraint(equalTo: tradeInfoView.topAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(titleLabel1)
        titleLabel1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        titleLabel1.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(infoLabel1)
        infoLabel1.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        infoLabel1.leadingAnchor.constraint(equalTo: titleLabel1.trailingAnchor).isActive = true
        infoLabel1.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(titleLabel2)
        titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: defaultViewsDistance).isActive = true
        titleLabel2.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(infoLabel2)
        infoLabel2.topAnchor.constraint(equalTo: infoLabel1.bottomAnchor, constant: defaultViewsDistance).isActive = true
        infoLabel2.leadingAnchor.constraint(equalTo: titleLabel2.trailingAnchor).isActive = true
        infoLabel2.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(titleLabel3)
        titleLabel3.topAnchor.constraint(equalTo: titleLabel2.bottomAnchor, constant: defaultViewsDistance).isActive = true
        titleLabel3.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(infoLabel3)
        infoLabel3.topAnchor.constraint(equalTo: infoLabel2.bottomAnchor, constant: defaultViewsDistance).isActive = true
        infoLabel3.leadingAnchor.constraint(equalTo: titleLabel3.trailingAnchor).isActive = true
        infoLabel3.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
    }
    
    func setup(with model: ViewModel) {
        // TODO: replace the hardcoded text and images when the BE is ready
    }
}
