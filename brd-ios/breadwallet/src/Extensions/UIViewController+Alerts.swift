//
//  UIViewController+Alerts.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-04.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

extension UIViewController {

    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: L10n.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorMessageAndDismiss(_ message: String) {
        let alert = UIAlertController(title: L10n.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String, buttonLabel: String = L10n.Button.ok) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonLabel, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertAndDismiss(title: String, message: String, buttonLabel: String = L10n.Button.ok) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonLabel, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showToastMessage(message: String) {
        let messageView = UIView()
        messageView.setupCustomMargins(all: .large)
        messageView.backgroundColor = LightColors.error
        messageView.layer.cornerRadius = 12
        
        let textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.font = Fonts.Body.two
        textLabel.text = message
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.clipsToBounds  =  true
        
        guard let superview = navigationController?.topViewController?.view else {
            return
        }
        superview.addSubview(messageView)
        messageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(Margins.large.rawValue)
            make.trailing.equalToSuperview().offset(-Margins.large.rawValue)
            make.height.equalTo(72)
        }
        messageView.layoutIfNeeded()
        messageView.alpha = 1
        
        messageView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalTo(messageView.snp.margins)
        }
        
        UIView.animate(withDuration: 4.0) {
            messageView.alpha = 0
        } completion: { _ in
            messageView.removeFromSuperview()
        }
    }
}
