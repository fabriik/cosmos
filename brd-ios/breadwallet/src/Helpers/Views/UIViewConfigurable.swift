// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol UIViewConfigurable: Roundable, Shadowable {
    var isRounded: Bool { get set }
    var isShadowed: Bool { get set }
    var backgroundColor: UIColor? { get }
}

struct UIViewConfiguration: UIViewConfigurable {
    var isRounded: Bool = false
    var isShadowed: Bool = false
    
    var isCircle: Bool = false
    var cornerRadius: CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear
    var backgroundColor: UIColor? = .clear
    
    var shadowColor: CGColor = UIColor.white.cgColor
    var shadowOpacity: Float = 0
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = 0
    
    enum Preset {
        
        var configuration: UIViewConfiguration {
            return UIViewConfiguration()
        }
    }
}

extension UIView: ViewConfigurable {
    func configure(with viewConfig: UIViewConfigurable?) {
        guard let viewConfig = viewConfig else { return }
        
        backgroundColor = viewConfig.backgroundColor
        
        if viewConfig.isRounded {
            clipsToBounds = viewConfig.cornerRadius != 0
            layer.cornerRadius = viewConfig.cornerRadius
            layer.borderWidth = viewConfig.borderWidth
            layer.borderColor = viewConfig.borderColor.cgColor
            clipsToBounds = true
            layer.masksToBounds = true
        } else if viewConfig.isShadowed {
            layer.shadowColor = viewConfig.shadowColor
            layer.shadowOpacity = viewConfig.shadowOpacity
            layer.shadowOffset = viewConfig.shadowOffset
            layer.shadowRadius = viewConfig.shadowRadius
            clipsToBounds = false
            layer.masksToBounds = false
        }
    }
}
