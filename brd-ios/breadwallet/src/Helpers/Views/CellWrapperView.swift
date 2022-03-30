// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum WrapperViewType {
    case normal
}

/// Wrapps UIView in a TableViewCell, so any UIView can be used in a UITableView
class CellWrapperView<T: UIView>: UITableViewCell, Identifiable {
    static var identifier: String { return classIdentifier }
    
    class var classIdentifier: String {
        return "WrappedCell\(String(describing: T.self))"
    }
    
    struct ViewConfigurable {
        var roundedViewConfig: UIViewConfigurable
    }
    
    private lazy var wrappedView: T = {
        return T()
    }()
    
    private lazy var containerView: RoundedView = {
        let view = RoundedView()
        view.backgroundColor = UIColor.darkGray
        view.setupDefaultRoundable()
        
        return view
    }()
    
    var viewToHighlight: UIView?
    var viewToShadow: UIView?
    
    private var type: WrapperViewType = .normal
    
    override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = identifier) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init(type: WrapperViewType = .normal) {
        self.init(frame: .zero)
        
        setup(type: type)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        updateContainerColor(isSelected: selected)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        updateContainerColor(isSelected: highlighted)
    }
    
    private func updateContainerColor(isSelected: Bool) {
        guard selectionStyle != .none else { return }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            switch self.type {
            case .normal:
                let viewToShadowExists = self.viewToShadow != nil
                let viewToHighlightExists = self.viewToHighlight != nil
                let shadowAndHighlightViewsExists = viewToShadowExists && viewToHighlightExists
                
                if viewToShadowExists {
                    self.styleViewToShadow(isSelected)
                } else if viewToHighlightExists {
                    self.styleViewToHighlight(isSelected)
                } else if shadowAndHighlightViewsExists {
                    self.styleViewToShadow(isSelected)
                    self.styleViewToHighlight(isSelected)
                }
            }
        }
    }
    
    func styleViewToShadow(_ isSelected: Bool) {
        viewToShadow?.alpha = isSelected ? 1.0 : 0.0
    }
    
    func styleViewToHighlight(_ isSelected: Bool) {
        viewToHighlight?.backgroundColor = isSelected ? UIColor.lightGray.withAlphaComponent(0.2) : .clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
        case .normal:
            super.touchesBegan(touches, with: event)
            
        }
    }
    
    func configure(with viewConfig: ViewConfigurable) {
        configure(with: viewConfig.roundedViewConfig)
    }
    
    func setup(type: WrapperViewType = .normal) {
        backgroundColor = .clear
        selectionStyle = .none
        
        switch type {
        case .normal:
            setupNormal()
            
        }
    }
    
    func setupNormal() {
        type = .normal
        containerView.removeFromSuperview()
        wrappedView.removeFromSuperview()
        
        contentView.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        wrappedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        contentView.preservesSuperviewLayoutMargins = false
        contentView.directionalLayoutMargins = .zero
    }
    
    func setup(_ closure: (T) -> Void) {
        closure(wrappedView)
    }
}
