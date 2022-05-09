// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

protocol Identifiable {
    static var identifier: String { get }
    static var className: AnyClass { get }
}

extension Identifiable where Self: UIView {
    public static var identifier: String {
        return String(describing: self)
    }
    
    public static var className: AnyClass {
        return Self.self
    }
}

extension UITableView {
    public func register<T: Identifiable>(_ cell: T.Type) {
        register(cell.className, forCellReuseIdentifier: cell.identifier)
    }
    
    public func dequeueReusableCell<T: Identifiable>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
    
    public func registerHeaderFooter<T: Identifiable>(_ cell: T.Type) {
        register(cell.className, forHeaderFooterViewReuseIdentifier: cell.identifier)
    }
    
    public func dequeueHeaderFooter<T: Identifiable>() -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T
    }
}

extension UICollectionView {
    public func register<T: Identifiable>(_ cell: T.Type) {
        register(cell.className, forCellWithReuseIdentifier: cell.identifier)
    }
    
    public func dequeueReusableCell<T: Identifiable>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
}

// MARK: - UI Tweaks

struct TableViewConfiguration: Configurable {
    
}

extension UITableView: ViewProtocol {
    func configure(with config: TableViewConfiguration?) {
        
    }
}
extension UITableView {
    func emptyHeaderFooterView() {
        tableHeaderView = UIView(frame: CGRect(origin: .zero,
                                               size: CGSize(width: 0,
                                                            height: CGFloat.leastNonzeroMagnitude)))
        tableFooterView = UIView(frame: CGRect(origin: .zero,
                                               size: CGSize(width: 0,
                                                            height: CGFloat.leastNonzeroMagnitude)))
    }
    
    func setupDefault() {
        separatorStyle = .none
        delaysContentTouches = false
        keyboardDismissMode = .interactive
        estimatedRowHeight = UITableView.automaticDimension
        rowHeight = UITableView.automaticDimension
        backgroundColor = .clear
    }
}
