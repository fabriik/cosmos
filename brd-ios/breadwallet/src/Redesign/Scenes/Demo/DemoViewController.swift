//
//  DemoViewController.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//
//

import UIKit
import WalletKit

class DemoViewController: BaseTableViewController<DemoCoordinator,
                          DemoInteractor,
                          DemoPresenter,
                          DemoStore>,
                          DemoResponseDisplays {
    typealias Models = DemoModels
    
    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<FETimerView>.self)
    }
    
    override func prepareData() {
        sections = [
            Models.Section.timer
        ]
        
        sectionRows = [
            Models.Section.timer: [
                TimerViewModel(duration: 10, image: .imageName("timelapse"), finished: {
                    print("Done!")
                }, repeats: true)
            ]
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - User Interaction
    // MARK: - DemoResponseDisplay
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .button:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        case .timer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ScrollableButtonsView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ScrollableButtonsViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init(background: Presets.Background.Primary.normal,
                                       buttons: [
                                        Presets.Button.icon
                                       ]
                                      ))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, timerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<FETimerView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? TimerViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    // MARK: - Additional Helpers
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sections[indexPath.section].hashValue == Models.Section.label.hashValue else { return }
        
        toggleInfo()
    }
    
    func toggleInfo() {
        guard blurView?.superview == nil else {
            hideInfo()
            return
        }
        
        showInfo()
    }
    
    func showInfo() {
        // TODO: this is demo code.. no review required XD
        toggleBlur(animated: true)
        guard let blur = blurView else { return }
        let popup = FEPopupView()
        view.insertSubview(popup, aboveSubview: blur)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.snp.topMargin)
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.layoutIfNeeded()
        popup.alpha = 0
        
        var text = "almost done... "
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        text += text
        
        popup.configure(with: Presets.Popup.normal)
        popup.setup(with: .init(title: .text("This is a title"),
                                body: text,
                                buttons: [
                                    .init(title: "Donate"),
                                    .init(title: "Donate", image: "close"),
                                    .init(image: "close")
                                ]))
        popup.closeCallback = { [weak self] in
            self?.hideInfo()
        }
        
        popup.buttonCallbacks = [
            { print("Donated 10$! Thanks!") }
        ]
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 1
        }
    }
    
    @objc func hideInfo() {
        guard let popup = view.subviews.first(where: { $0 is FEPopupView }) else { return }
        
        toggleBlur(animated: true)
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 0
        } completion: { _ in
            popup.removeFromSuperview()
        }
    }
}
