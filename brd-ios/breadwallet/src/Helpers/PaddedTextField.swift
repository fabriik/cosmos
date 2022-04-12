// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 48)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func setPasswordToggleImage(_ button: UIButton) {
        isSecureTextEntry ?
        button.setImage(UIImage(named: "KYC ShowPassword"), for: .normal) :
        button.setImage(UIImage(named: "KYC HidePassword"), for: .selected)
    }
}
