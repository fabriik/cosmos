//
//  AboutViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-05.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {

    private let titleLabel = UILabel(font: .customBold(size: 26.0), color: .almostBlack)
    private let logo = UIImageView(image: #imageLiteral(resourceName: "LogoBlue"))
    private let logoBackground = MotionGradientView()
    private let walletID = WalletIDCell()
    private let privacy = UIButton(type: .system)
    private let terms = UIButton(type: .system)
    private let footer = UILabel.wrapping(font: .customBody(size: 13.0), color: Theme.primaryText)
    
    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setData()
        setActions()
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(logo)
        view.addSubview(walletID)
        view.addSubview(privacy)
        view.addSubview(terms)
        view.addSubview(footer)
    }

    private func addConstraints() {
        titleLabel.constrain([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2]) ])
        logo.constrain([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: C.padding[3]),
            logo.widthAnchor.constraint(equalToConstant: 50),
            logo.heightAnchor.constraint(equalToConstant: 50)])
        
        let verticalMargin = (E.isIPhone6OrSmaller) ? C.padding[1] : C.padding[2]
        
        walletID.constrain([
            walletID.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: verticalMargin),
            walletID.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            walletID.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        terms.constrain([
            terms.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            terms.topAnchor.constraint(equalTo: walletID.bottomAnchor, constant: verticalMargin)])
        privacy.constrain([
            privacy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacy.topAnchor.constraint(equalTo: terms.bottomAnchor)])
        footer.constrain([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[3]),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[3]),
            footer.topAnchor.constraint(equalTo: privacy.bottomAnchor, constant: verticalMargin)])
    }

    private func setData() {
        view.backgroundColor = .darkBackground
        logo.tintColor = .darkBackground
        titleLabel.text = S.About.title
        
        privacy.setTitle(S.About.privacy, for: .normal)
        privacy.titleLabel?.font = UIFont.customBody(size: 13.0)
        privacy.tintColor = .primaryButton
        
        terms.setTitle(S.About.terms, for: .normal)
        terms.titleLabel?.font = UIFont.customBody(size: 13.0)
        terms.tintColor = .primaryButton
        
        footer.textAlignment = .center
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            footer.text = String(format: S.About.footer, version, build)
        }
    }

    private func setActions() {
        privacy.tap = strongify(self) { myself in
            myself.presentURL(string: C.privacyPolicy, title: self.privacy.titleLabel?.text ?? "")
        }
        
        terms.tap = strongify(self) { myself in
            myself.presentURL(string: C.termsAndConditions, title: self.terms.titleLabel?.text ?? "")
        }
    }

    private func presentURL(string: String, title: String) {
        guard let url = URL(string: string) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: title))
        
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
