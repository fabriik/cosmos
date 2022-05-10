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

protocol MainRoutes: CoordinatableRoutes {}

class BaseTableViewController<C: MainRoutes,
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
//        view.backgroundColor = R.color.blareBackgroundColor()
//        tableView.backgroundColor = R.color.blareBackgroundColor()
//        tableView.snp.makeConstraints { make in
//            make.trailing.centerX.equalToSuperview()
//            make.top.equalTo(view.snp.topMargin)
//            make.bottom.equalTo(view.snp.bottomMargin)
//        }
//
//        tableView.backgroundView = emptyStateView
//        emptyStateView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().inset(MarginSize.extraExtraLarge.value)
//            make.leading.trailing.equalToSuperview().inset(MarginSize.small.value)
//        }
//
//        tableView.register(WrapperCell<WrapperView<AnimationImageView>>.self)
//        tableView.register(WrapperCell<WrapperView<MosaicView>>.self)
//        tableView.register(WrapperCell<HorizontalItemView>.self)
//        tableView.register(WrapperCell<ControllsView>.self)
//        tableView.register(WrapperCell<VerticalItemView>.self)
//        tableView.register(WrapperCell<ItemsCollectionView<VerticalItemView>>.self)
//        tableView.register(WrapperCell<ItemsCollectionView<WideVerticalView>>.self)
//        tableView.register(WrapperCell<ProfileView>.self)
//        tableView.register(WrapperCell<EmptyStateView>.self)
//        tableView.register(WrapperCell<UILabel>.self)
//        tableView.register(WrapperCell<BlareButton>.self)
//        tableView.register(WrapperCell<TextFieldStack>.self)
//        tableView.registerHeaderFooter(TableViewHeaderFooterWrapperView<TitleView>.self)
//        tableView.registerHeaderFooter(TableViewHeaderFooterWrapperView<BlareButton>.self)
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
        return self.tableView(tableView, accessoryViewForType: type) { [weak self] in
            self?.tableView(tableView, didSelectHeaderIn: section)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = (sections[section] as? Sectionable)?.footer
        return self.tableView(tableView, accessoryViewForType: type) { [weak self] in
            self?.tableView(tableView, didSelectFooterIn: section)
        }
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, accessoryViewForType type: AccessoryType?, callback: @escaping (() -> Void)) -> UIView? {
        return nil
//        let view: UIView?
//        switch type {
//        case .plain(let string):
//            view = self.tableView(tableView, supplementaryViewWith: string)
//
//        case .attributed(let attributedString):
//            view = self.tableView(tableView, supplementaryViewWith: attributedString)
//
//        case .action(let title):
//            view = self.tableView(tableView, supplementaryViewWith: title, callback: callback)
//
//        default:
//            view = UIView(frame: .zero)
//        }
//        (view as? CustomMarginable)?.setupCustomMargins(vertical: .small, horizontal: .small)
//
//        return view
    }
    
//    private func tableView(_ tableView: UITableView, supplementaryViewWith text: String?) -> UIView? {
//        guard let view: TableViewHeaderFooterWrapperView<TitleView> = tableView.dequeueHeaderFooter(),
//              let text = text
//        else { return UIView(frame: .zero) }
//
//        view.setup { view in
//            view.setup(with: .init(text: text))
//            view.configure(with: AppFonts.message.font)
//        }
//
//        return view
//    }
//
//    private func tableView(_ tableView: UITableView, supplementaryViewWith attributedText: NSAttributedString?) -> UIView? {
//        guard let view: TableViewHeaderFooterWrapperView<TitleView> = tableView.dequeueHeaderFooter(),
//              let text = attributedText
//        else { return UIView(frame: .zero) }
//
//        view.setup { view in
//            view.setup(with: .init(attributedText: text))
//            view.configure(with: AppFonts.message.font)
//        }
//
//        return view
//    }
//
//    private func tableView(_ tableView: UITableView, supplementaryViewWith buttonTitle: String?, callback: @escaping (() -> Void)) -> UIView? {
//        guard let view: TableViewHeaderFooterWrapperView<BlareButton> = tableView.dequeueHeaderFooter(),
//              let text = buttonTitle
//        else { return UIView(frame: .zero) }
//
//        view.setup { view in
//            view.setup(with: .init(title: text))
//            view.touchUp = { _ in callback() }
//        }
//
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, imageCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<WrapperView<AnimationImageView>> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? AnimationImageView.Model
//        else { return UITableViewCell() }
//
//        cell.setup { wrapperView in
//            wrapperView.setup { view in
//                view.setup(with: item)
//                view.snp.removeConstraints()
//                view.snp.makeConstraints { make in
//                    make.top.bottom.equalToSuperview()
//                    make.centerX.equalToSuperview()
//                    make.width.height.equalTo(ViewSize.extraLarge.value)
//                }
//            }
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, horizontalItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<HorizontalItemView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? LibraryDisplayable
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: ItemType.modelFor(item: item))
//            view.accessoryTapped = { [weak self] in
//                self?.interactor?.showMenu(viewAction: .init(item: item))
//            }
//        }
//        cell.setupCustomMargins(top: .extraSmall, leading: .smaller, bottom: .extraSmall, trailing: .mediumSmall)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, controllsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<ControllsView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]] as? [ControlModel]
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: item)
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, profileCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<VerticalItemView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? LibraryDisplayable
//        else { return UITableViewCell() }
//
//        cell.setup { [weak self] view in
//            view.setup(with: ItemType.modelFor(item: item, type: .medium))
//            view.longPressCallback = { self?.interactor?.showMenu(viewAction: .init(item: item)) }
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, mosaicCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<VerticalItemView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? Mosaic
//        else { return UITableViewCell() }
//
//        cell.setup { $0.setup(with: ItemType.modelFor(item: item, type: .medium)) }
//
//        return cell
//    }
//
//    // TODO: this methos should be removed
//    func tableView(_ tableView: UITableView, collectionViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<ItemsCollectionView<VerticalItemView>> = tableView.dequeueReusableCell(for: indexPath),
//              let items = sectionRows[sections[indexPath.section]]?[indexPath.row] as? [LibraryDisplayable]
//        else { return UITableViewCell() }
//
//        let models = items.compactMap { ItemType.modelFor(item: $0, type: .small) }
//
//        cell.setup { [weak self] view in
//            view.setup(with: .init(models))
//            view.didSelectItem = { collectionIndexPath in self?.didSelectItem(in: indexPath.section, row: collectionIndexPath.row) }
//            view.didLongPressItem = { collectionIndexPath in self?.didLongPressItem(in: indexPath.section, row: collectionIndexPath.row) }
//        }
//
//        return cell
//    }
//
//    func tableView<V: ItemsViewProtocol>(_ tableView: UITableView, customCollectionViewCellForRowAt indexPath: IndexPath) -> WrapperCell<ItemsCollectionView<V>>? {
//        guard let cell: WrapperCell<ItemsCollectionView<V>> = tableView.dequeueReusableCell(for: indexPath),
//              let items = sectionRows[sections[indexPath.section]]?[indexPath.row] as? [V.Model]
//        else { return self.tableView(tableView, collectionViewCellForRowAt: indexPath) as? WrapperCell<ItemsCollectionView<V>> }
//
//        cell.setup { [weak self] view in
//            view.setup(with: items)
//            view.didSelectItem = { collectionIndexPath in self?.didSelectItem(in: indexPath.section, row: collectionIndexPath.row) }
//            view.didLongPressItem = { collectionIndexPath in self?.didLongPressItem(in: indexPath.section, row: collectionIndexPath.row) }
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, profileDetailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let section = sections[indexPath.section]
//        guard let cell: WrapperCell<ProfileView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[section]?.first as? ProfileView.Model
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: item)
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, emptyStateCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<EmptyStateView> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? EmptyStateView.Model
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: item)
//        }
//
//        cell.setupCustomMargins(vertical: .small, horizontal: .small)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, textCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<UILabel> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? String
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.text = item
//            view.font = AppFonts.message.font
//            view.textColor = R.color.subtextColor()
//            view.numberOfLines = 0
//            view.lineBreakMode = .byWordWrapping
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<BlareButton> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? BlareButton.Model
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: item)
//        }
//        cell.setupCustomMargins(vertical: .small, horizontal: .medium)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, textFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: WrapperCell<TextFieldStack> = tableView.dequeueReusableCell(for: indexPath),
//              let item = sectionRows[sections[indexPath.section]]?[indexPath.row] as? TextFieldStackType
//        else { return UITableViewCell() }
//
//        cell.setup { view in
//            view.setup(with: .init(fieldType: item))
//        }
//
//        return cell
//    }

    // MARK: UserInteractions
    func didSelectItem(in section: Int, row: Int) {
    }

    func didLongPressItem(in section: Int, row: Int) {
    }
}
