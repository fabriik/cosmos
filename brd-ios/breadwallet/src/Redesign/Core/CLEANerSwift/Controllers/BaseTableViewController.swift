// 
//  BaseTableViewController.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseTableViewController<C: CoordinatableRoutes,
                              I: Interactor & FetchViewActions,
                              P: Presenter & FetchActionResponses,
                              DS: BaseDataStore & NSObject>: VIPTableViewController<C, I, P, DS>,
                                                                              FetchResponseDisplays {
    override var isModalDismissableEnabled: Bool { return true }
    override var dismissText: String { return "close" }

    // MARK: - Cleaner Swift Setup

    lazy var emptyStateView: UIView = {
        let view = UIView()
        return view
    }()

    override func setupSubviews() {
        super.setupSubviews()
        
        // TODO: register proper accessoryViews
        tableView.registerAccessoryView(WrapperAccessoryView<UILabel>.self)
        tableView.registerAccessoryView(WrapperAccessoryView<UIButton>.self)
        // TODO: register base cells
        // eg.
//        tableView.register(WrapperCell<WrapperView<AnimationImageView>>.self)
    }

    override func prepareData() {
        super.prepareData()
        interactor?.getData(viewAction: .init())
    }

    // MARK: ResponseDisplay
    func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        sections = responseDisplay.sections
        sectionRows = responseDisplay.sectionRows
        tableView.reloadData()
        tableView.backgroundView?.isHidden = !sections.isEmpty
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return sectionRows[section]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = (sections[section] as? Sectionable)?.header
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectHeaderIn: section)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = (sections[section] as? Sectionable)?.footer
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectFooterIn: section)
        }
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, accessoryViewForType type: AccessoryType?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        let view: UIView?
        switch type {
        case .plain(let string):
            view = self.tableView(tableView, supplementaryViewWith: string)

        case .attributed(let attributedString):
            view = self.tableView(tableView, supplementaryViewWith: attributedString)

        case .action(let title):
            view = self.tableView(tableView, supplementaryViewWith: title, for: section, callback: callback)

        default:
            view = UIView(frame: .zero)
        }
        (view as? Marginable)?.setupCustomMargins(vertical: .small, horizontal: .small)

        return view
    }
    
    private func tableView(_ tableView: UITableView, supplementaryViewWith text: String?) -> UIView? {
        // TODO: custom label
        guard let view: WrapperAccessoryView<UILabel> = tableView.dequeueHeaderFooter(),
              let text = text
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.text = text
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith attributedText: NSAttributedString?) -> UIView? {
        // TODO: custom label
        guard let view: WrapperAccessoryView<UILabel> = tableView.dequeueHeaderFooter(),
              let text = attributedText
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.attributedText = text
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith buttonTitle: String?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        // TODO: custom button (actionButton look alike?)
        guard let view: WrapperAccessoryView<UIButton> = tableView.dequeueHeaderFooter(),
              let text = buttonTitle
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.setTitle(text, for: .normal)
            // TODO: add callback to suplementaryViewTapped
        }

        return view
    }
    
    func tableView(_ tableView: UITableView, supplementaryViewTapped section: Int) {
        // TODO: override in class to handle suplementary button events
    }

// TODO: add dequeue methos for all standard cells

    // MARK: UserInteractions
    func didSelectItem(in section: Int, row: Int) {
    }

    func didLongPressItem(in section: Int, row: Int) {
    }
}
