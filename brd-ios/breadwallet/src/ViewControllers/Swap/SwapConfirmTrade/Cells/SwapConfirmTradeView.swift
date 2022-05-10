//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SwapConfirmTradeView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {}
    
    private lazy var currencyStack: UIStackView = {
        let currencyStack = UIStackView()
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        currencyStack.backgroundColor = .clear
        currencyStack.axis = .horizontal
        currencyStack.spacing = 4
        
        return currencyStack
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
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .almostBlack
        label.font = UIFont(name: "AvenirNext-Bold", size: 30)
        label.text = ">"
        
        return label
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
        let tradeForLabel = UILabel()
        tradeForLabel.translatesAutoresizingMaskIntoConstraints = false
        tradeForLabel.textAlignment = .center
        tradeForLabel.textColor = .almostBlack
        tradeForLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        tradeForLabel.text = "For"
        
        return tradeForLabel
    }()
    
    private lazy var tradeForImageView: UIImageView = {
        let tradeForImageView = UIImageView()
        tradeForImageView.translatesAutoresizingMaskIntoConstraints = false
        tradeForImageView.image = UIImage(named: "LogoBlue")
        tradeForImageView.contentMode = .scaleAspectFit
        tradeForImageView.layer.cornerRadius = 8
        tradeForImageView.backgroundColor = .clear
        
        return tradeForImageView
    }()
    
    private lazy var tradeForCurrencyLabel: UILabel = {
        let tradeForCurrencyLabel = UILabel()
        tradeForCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        tradeForCurrencyLabel.textAlignment = .center
        tradeForCurrencyLabel.textColor = .almostBlack
        tradeForCurrencyLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        tradeForCurrencyLabel.text = "86.4012 BRD"
        
        return tradeForCurrencyLabel
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
    
    private lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.textAlignment = .left
        priceLabel.textColor = .almostBlack
        priceLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        priceLabel.text = "Price:"
        
        return priceLabel
    }()
    
    private lazy var priceInfoLabel: UILabel = {
        let priceInfoLabel = UILabel()
        priceInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        priceInfoLabel.textAlignment = .right
        priceInfoLabel.textColor = .almostBlack
        priceInfoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        priceInfoLabel.text = "1 ETH = 1.562.589 BRD"
        
        return priceInfoLabel
    }()
    
    private lazy var deliveryLabel: UILabel = {
        let deliveryLabel = UILabel()
        deliveryLabel.translatesAutoresizingMaskIntoConstraints = false
        deliveryLabel.textAlignment = .left
        deliveryLabel.textColor = .almostBlack
        deliveryLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        deliveryLabel.text = "Delivery:"
        
        return deliveryLabel
    }()
    
    private lazy var deliveryInfoLabel: UILabel = {
        let deliveryInfoLabel = UILabel()
        deliveryInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        deliveryInfoLabel.textAlignment = .right
        deliveryInfoLabel.textColor = .almostBlack
        deliveryInfoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        deliveryInfoLabel.text = "1-6 hours"
        
        return deliveryInfoLabel
    }()
    
    private lazy var feeLabel: UILabel = {
        let feeLabel = UILabel()
        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        feeLabel.textAlignment = .left
        feeLabel.textColor = .almostBlack
        feeLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        feeLabel.text = "Fee:"
        
        return feeLabel
    }()
    
    private lazy var feeInfoLabel: UILabel = {
        let feeInfoLabel = UILabel()
        feeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        feeInfoLabel.textAlignment = .right
        feeInfoLabel.textColor = .almostBlack
        feeInfoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        feeInfoLabel.text = "0.0011 ETH"
        
        return feeInfoLabel
    }()
    
    private lazy var totalChargeLabel: UILabel = {
        let totalChargeLabel = UILabel()
        totalChargeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalChargeLabel.textAlignment = .left
        totalChargeLabel.textColor = .almostBlack
        totalChargeLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        totalChargeLabel.text = "Total Charge:"
        
        return totalChargeLabel
    }()
    
    private lazy var totalChargeInfoLabel: UILabel = {
        let totalChargeInfoLabel = UILabel()
        totalChargeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        totalChargeInfoLabel.textAlignment = .right
        totalChargeInfoLabel.textColor = .almostBlack
        totalChargeInfoLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        totalChargeInfoLabel.text = "0.0799 ETH"
        
        return totalChargeInfoLabel
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
        
        tradeInfoView.addSubview(priceLabel)
        priceLabel.topAnchor.constraint(equalTo: tradeInfoView.topAnchor).isActive = true
        priceLabel.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(priceInfoLabel)
        priceInfoLabel.topAnchor.constraint(equalTo: tradeInfoView.topAnchor).isActive = true
        priceInfoLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor).isActive = true
        priceInfoLabel.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(deliveryLabel)
        deliveryLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        deliveryLabel.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(deliveryInfoLabel)
        deliveryInfoLabel.topAnchor.constraint(equalTo: priceInfoLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        deliveryInfoLabel.leadingAnchor.constraint(equalTo: deliveryLabel.trailingAnchor).isActive = true
        deliveryInfoLabel.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(feeLabel)
        feeLabel.topAnchor.constraint(equalTo: deliveryLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        feeLabel.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(feeInfoLabel)
        feeInfoLabel.topAnchor.constraint(equalTo: deliveryInfoLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        feeInfoLabel.leadingAnchor.constraint(equalTo: feeLabel.trailingAnchor).isActive = true
        feeInfoLabel.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
        
        tradeInfoView.addSubview(totalChargeLabel)
        totalChargeLabel.topAnchor.constraint(equalTo: feeLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        totalChargeLabel.leadingAnchor.constraint(equalTo: tradeInfoView.leadingAnchor).isActive = true
        
        tradeInfoView.addSubview(totalChargeInfoLabel)
        totalChargeInfoLabel.topAnchor.constraint(equalTo: feeInfoLabel.bottomAnchor, constant: defaultViewsDistance).isActive = true
        totalChargeInfoLabel.leadingAnchor.constraint(equalTo: totalChargeLabel.trailingAnchor).isActive = true
        totalChargeInfoLabel.trailingAnchor.constraint(equalTo: tradeInfoView.trailingAnchor).isActive = true
    }
    
    func setup(with model: ViewModel) {
        // TODO: replace the hardcoded text and images when the BE is ready
    }
}
