//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension UITextField {
    func setPasswordToggleImage(_ button: UIButton) {
        isSecureTextEntry ?
        button.setImage(UIImage(named: "KYC ShowPassword"), for: .normal) :
        button.setImage(UIImage(named: "KYC HidePassword"), for: .selected)
    }
}
