//
//  WalletDisabledView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-05-01.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class WalletDisabledView: UIView {

    func setTimeLabel(string: String) {
        label.text = string
    }

    init() {
        blur = UIVisualEffectView()
        super.init(frame: .zero)
        setup()
    }

    func show() {
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.blur.effect = self.effect
        })
    }

    func hide(completion: @escaping () -> Void) {
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.blur.effect = nil
        }, completion: { _ in
            completion()
        })
    }

    var didTapReset: (() -> Void)? {
        didSet {
            reset.tap = didTapReset
        }
    }
    
    var didTapFaq: (() -> Void)? {
        didSet {
            faq.tap = didTapFaq
        }
    }
    
    var didCompleteWipeGesture: (() -> Void)?

    private let label = UILabel(font: Fonts.Title.five, color: Theme.primaryText)
    private let blur: UIVisualEffectView
    private let reset = BRDButton(title: L10n.UnlockScreen.resetPin, type: .primary)
    private let effect = UIBlurEffect(style: .regular)
    private let gr = UITapGestureRecognizer()
    private var tapCount = 0
    private let tapWipeCount = 12
    
    private lazy var faq: UIButton = {
        let faq = UIButton()
        faq.tintColor = Theme.primaryText
        faq.setBackgroundImage(UIImage(named: "faqIcon"), for: .normal)
        
        return faq
    }()
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.textColor = Theme.primaryText
        header.font = Fonts.Title.four
        header.textAlignment = .center
        header.text = L10n.UnlockScreen.walletDisabled
        
        return header
    }()
    
    private lazy var unlockWalletImage: UIImageView = {
        let unlockWalletImage = UIImageView(image: UIImage(named: "unlock-wallet"))
        unlockWalletImage.contentMode = .scaleAspectFit
        
        return unlockWalletImage
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = Theme.secondaryText
        descriptionLabel.font = Fonts.caption
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = L10n.UnlockScreen.walletDisabledDescription
        
        return descriptionLabel
    }()
    
    private func setup() {
        addSubviews()
        addConstraints()
        setData()
    }

    private func addSubviews() {
        addSubview(blur)
        addSubview(faq)
        addSubview(header)
        addSubview(label)
        addSubview(unlockWalletImage)
        addSubview(reset)
        addSubview(descriptionLabel)
    }

    private func addConstraints() {
        blur.constrain(toSuperviewEdges: nil)
        
        faq.constrain([
            faq.topAnchor.constraint(equalTo: blur.topAnchor, constant: 70),
            faq.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -C.padding[2])])
        
        header.constrain([
            header.topAnchor.constraint(equalTo: blur.topAnchor, constant: 170),
            header.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            header.heightAnchor.constraint(equalToConstant: C.padding[3])])
        
        label.constrain([
            header.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
            label.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: C.padding[3])])
        
        unlockWalletImage.constrain([
            unlockWalletImage.topAnchor.constraint(equalTo: label.bottomAnchor, constant: C.padding[8]),
            unlockWalletImage.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            unlockWalletImage.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
            unlockWalletImage.widthAnchor.constraint(equalToConstant: 190),
            unlockWalletImage.heightAnchor.constraint(equalToConstant: 240)])
        
        reset.constrain([
            reset.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            reset.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            reset.heightAnchor.constraint(equalToConstant: C.Sizes.buttonHeight)])
        
        descriptionLabel.constrain([
            descriptionLabel.topAnchor.constraint(equalTo: reset.bottomAnchor, constant: C.padding[1]),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[4]),
            descriptionLabel.centerXAnchor.constraint(equalTo: blur.centerXAnchor)])
    }

    private func setData() {
        label.textAlignment = .center
        label.addGestureRecognizer(gr)
        label.isUserInteractionEnabled = true
        gr.addTarget(self, action: #selector(didTap))
        faq.tintColor = .black
    }
    
    @objc private func didTap() {
        tapCount += 1
        if tapCount == tapWipeCount {
            didCompleteWipeGesture?()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
