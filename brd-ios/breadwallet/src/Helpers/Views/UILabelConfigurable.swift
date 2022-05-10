// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol UILabelConfigurable {
    var font: UIFont { get }
    var textColor: UIColor { get }
    var textAlignment: NSTextAlignment { get }
    var backgroundColor: UIColor? { get }
    var numberOfLines: Int { get }
    var lineBreakMode: NSLineBreakMode { get }
}

struct UILabelConfiguration: UILabelConfigurable {
    var font: UIFont = .systemFont(ofSize: 16)
    var textColor: UIColor = .almostBlack
    var textAlignment: NSTextAlignment = .left
    var backgroundColor: UIColor? = .clear
    var numberOfLines: Int = 0
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    
    enum Preset {
        case snackbar
        
        var configuration: UILabelConfiguration {
            return UILabelConfiguration()
        }
    }
}

extension UILabel {
    func configure(with config: UILabelConfigurable?) {
        font = config?.font
        textColor = config?.textColor
        textAlignment = config?.textAlignment ?? .left
        backgroundColor = config?.backgroundColor
        numberOfLines = config?.numberOfLines ?? 0
        lineBreakMode = config?.lineBreakMode ?? .byWordWrapping
    }
}
