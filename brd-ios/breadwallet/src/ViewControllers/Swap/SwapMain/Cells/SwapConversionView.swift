//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SwapConversionView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    // TODO: Move fonts to constants
    // TODO: Cleanup labels
    
    struct ViewModel: Hashable {
        let sendAmount: String?
        let receiveAmount: String?
        let sendCurrencyIcon: UIImage?
        let sendCurrencyName: String?
        let receiveCurrencyIcon: UIImage?
        let receiveCurrencyName: String?
    }
    
    private lazy var sendAmountTitleLabel: UILabel = {
        let sendAmountTitleLabel = UILabel()
        sendAmountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sendAmountTitleLabel.textAlignment = .left
        sendAmountTitleLabel.textColor = .gray1
        sendAmountTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
        sendAmountTitleLabel.text = "Pay With"
        
        return sendAmountTitleLabel
    }()
    
    private lazy var sendAmountLabel: UILabel = {
        let sendAmountLabel = UILabel()
        sendAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        sendAmountLabel.textAlignment = .left
        sendAmountLabel.textColor = .almostBlack
        sendAmountLabel.font = UIFont(name: "AvenirNext-Medium", size: 34)
        sendAmountLabel.text = "0.003"
        
        return sendAmountLabel
    }()
    
    private lazy var sendAmountcurrencyBackgroundView: UIView = {
        let sendAmountcurrencyBackgroundView = UIView()
        sendAmountcurrencyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        sendAmountcurrencyBackgroundView.backgroundColor = Theme.secondaryBackground.withAlphaComponent(0.1)
        
        return sendAmountcurrencyBackgroundView
    }()
    
    private lazy var sendAmountCurrencyImageView: UIImageView = {
        let currencyImageView = UIImageView()
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        currencyImageView.contentMode = .scaleAspectFit
        currencyImageView.backgroundColor = .systemPink
        currencyImageView.layer.cornerRadius = 6
        currencyImageView.layer.masksToBounds = true
        currencyImageView.clipsToBounds = true
        currencyImageView.image = UIImage(named: "TouchId-Large")
        
        return currencyImageView
    }()
    
    private lazy var sendAmountCurrencyTitleLabel: UILabel = {
        let sendAmountCurrencyTitleLabel = UILabel()
        sendAmountCurrencyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sendAmountCurrencyTitleLabel.textAlignment = .left
        sendAmountCurrencyTitleLabel.textColor = .almostBlack
        sendAmountCurrencyTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        sendAmountCurrencyTitleLabel.text = "BTC"
        
        return sendAmountCurrencyTitleLabel
    }()
    
    private lazy var separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = .gray3
        
        return separatorLine
    }()
    
    private lazy var receiveAmountTitleLabel: UILabel = {
        let receiveAmountTitleLabel = UILabel()
        receiveAmountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        receiveAmountTitleLabel.textAlignment = .left
        receiveAmountTitleLabel.textColor = .gray2
        receiveAmountTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
        receiveAmountTitleLabel.text = "Receive"
        
        return receiveAmountTitleLabel
    }()
    
    private lazy var receiveAmountLabel: UILabel = {
        let receiveAmountLabel = UILabel()
        receiveAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        receiveAmountLabel.textAlignment = .left
        receiveAmountLabel.textColor = .almostBlack
        receiveAmountLabel.font = UIFont(name: "AvenirNext-Medium", size: 34)
        receiveAmountLabel.text = "346.5363"
        
        return receiveAmountLabel
    }()
    
    private lazy var receiveAmountcurrencyBackgroundView: UIView = {
        let receiveAmountcurrencyBackgroundView = UIView()
        receiveAmountcurrencyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        receiveAmountcurrencyBackgroundView.backgroundColor = Theme.secondaryBackground.withAlphaComponent(0.1)
        
        return receiveAmountcurrencyBackgroundView
    }()
    
    private lazy var receiveAmountCurrencyImageView: UIImageView = {
        let currencyImageView = UIImageView()
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        currencyImageView.contentMode = .scaleAspectFit
        currencyImageView.backgroundColor = .systemPink
        currencyImageView.layer.cornerRadius = 6
        currencyImageView.layer.masksToBounds = true
        currencyImageView.clipsToBounds = true
        currencyImageView.image = UIImage(named: "TouchId-Large")
        
        return currencyImageView
    }()
    
    private lazy var receiveAmountCurrencyTitleLabel: UILabel = {
        let receiveAmountCurrencyTitleLabel = UILabel()
        receiveAmountCurrencyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        receiveAmountCurrencyTitleLabel.textAlignment = .left
        receiveAmountCurrencyTitleLabel.textColor = .almostBlack
        receiveAmountCurrencyTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        receiveAmountCurrencyTitleLabel.text = "BTC"
        
        return receiveAmountCurrencyTitleLabel
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        backgroundColor = Theme.primaryBackground
        
        addSubview(sendAmountTitleLabel)
        sendAmountTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        sendAmountTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        sendAmountTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sendAmountTitleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65).isActive = true
        
        addSubview(sendAmountLabel)
        sendAmountLabel.topAnchor.constraint(equalTo: sendAmountTitleLabel.bottomAnchor, constant: 2).isActive = true
        sendAmountLabel.leadingAnchor.constraint(equalTo: sendAmountTitleLabel.leadingAnchor).isActive = true
        sendAmountLabel.heightAnchor.constraint(equalToConstant: 56).isActive = true
        sendAmountLabel.widthAnchor.constraint(equalTo: sendAmountTitleLabel.widthAnchor).isActive = true
        
        addSubview(sendAmountcurrencyBackgroundView)
        
        sendAmountcurrencyBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sendAmountcurrencyBackgroundView.bottomAnchor.constraint(equalTo: sendAmountLabel.bottomAnchor).isActive = true
        sendAmountcurrencyBackgroundView.leadingAnchor.constraint(equalTo: sendAmountTitleLabel.trailingAnchor).isActive = true
        sendAmountcurrencyBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        sendAmountcurrencyBackgroundView.addSubview(sendAmountCurrencyTitleLabel)
        sendAmountcurrencyBackgroundView.addSubview(sendAmountCurrencyImageView)
        
        sendAmountCurrencyImageView.centerYAnchor.constraint(equalTo: sendAmountcurrencyBackgroundView.centerYAnchor).isActive = true
        sendAmountCurrencyImageView.trailingAnchor.constraint(equalTo: sendAmountCurrencyTitleLabel.leadingAnchor, constant: -8).isActive = true
        sendAmountCurrencyImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sendAmountCurrencyImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        sendAmountCurrencyTitleLabel.centerYAnchor.constraint(equalTo: sendAmountcurrencyBackgroundView.centerYAnchor).isActive = true
        sendAmountCurrencyTitleLabel.centerXAnchor.constraint(equalTo: sendAmountcurrencyBackgroundView.centerXAnchor).isActive = true
        
        addSubview(separatorLine)
        separatorLine.topAnchor.constraint(equalTo: sendAmountLabel.bottomAnchor).isActive = true
        separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(receiveAmountTitleLabel)
        receiveAmountTitleLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8).isActive = true
        receiveAmountTitleLabel.leadingAnchor.constraint(equalTo: sendAmountLabel.leadingAnchor).isActive = true
        receiveAmountTitleLabel.heightAnchor.constraint(equalTo: sendAmountTitleLabel.heightAnchor).isActive = true
        receiveAmountTitleLabel.widthAnchor.constraint(equalTo: sendAmountTitleLabel.widthAnchor).isActive = true
        
        addSubview(receiveAmountLabel)
        receiveAmountLabel.topAnchor.constraint(equalTo: receiveAmountTitleLabel.bottomAnchor, constant: 2).isActive = true
        receiveAmountLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        receiveAmountLabel.leadingAnchor.constraint(equalTo: receiveAmountTitleLabel.leadingAnchor).isActive = true
        receiveAmountLabel.heightAnchor.constraint(equalTo: sendAmountLabel.heightAnchor).isActive = true
        receiveAmountLabel.widthAnchor.constraint(equalTo: receiveAmountTitleLabel.widthAnchor).isActive = true
        
        addSubview(receiveAmountcurrencyBackgroundView)
        receiveAmountcurrencyBackgroundView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor).isActive = true
        receiveAmountcurrencyBackgroundView.bottomAnchor.constraint(equalTo: receiveAmountLabel.bottomAnchor).isActive = true
        receiveAmountcurrencyBackgroundView.leadingAnchor.constraint(equalTo: receiveAmountLabel.trailingAnchor).isActive = true
        receiveAmountcurrencyBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        receiveAmountcurrencyBackgroundView.addSubview(receiveAmountCurrencyTitleLabel)
        receiveAmountcurrencyBackgroundView.addSubview(receiveAmountCurrencyImageView)
        
        receiveAmountCurrencyImageView.centerYAnchor.constraint(equalTo: receiveAmountcurrencyBackgroundView.centerYAnchor).isActive = true
        receiveAmountCurrencyImageView.trailingAnchor.constraint(equalTo: receiveAmountCurrencyTitleLabel.leadingAnchor, constant: -8).isActive = true
        receiveAmountCurrencyImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        receiveAmountCurrencyImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        receiveAmountCurrencyTitleLabel.centerYAnchor.constraint(equalTo: receiveAmountcurrencyBackgroundView.centerYAnchor).isActive = true
        receiveAmountCurrencyTitleLabel.centerXAnchor.constraint(equalTo: receiveAmountcurrencyBackgroundView.centerXAnchor).isActive = true
        
    }
    
    func setup(with model: ViewModel) {
        if let sendAmount = model.sendAmount {
            sendAmountLabel.text = sendAmount
        }
        
        if let receiveAmount = model.receiveAmount {
            receiveAmountLabel.text = receiveAmount
        }
        
        if let sendCurrencyIcon = model.sendCurrencyIcon {
            sendAmountCurrencyImageView.image = sendCurrencyIcon
        }
        
        if let sendCurrencyName = model.sendCurrencyName {
            sendAmountCurrencyTitleLabel.text = sendCurrencyName
        }
        
        if let receiveCurrencyIcon = model.receiveCurrencyIcon {
            receiveAmountCurrencyImageView.image = receiveCurrencyIcon
        }
        
        if let receiveCurrencyName = model.receiveCurrencyName {
            receiveAmountCurrencyTitleLabel.text = receiveCurrencyName
        }
    }
}
