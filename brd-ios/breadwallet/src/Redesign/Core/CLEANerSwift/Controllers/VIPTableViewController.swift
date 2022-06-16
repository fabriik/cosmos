//
//  VIPTableViewController.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

class VIPTableViewController<C: CoordinatableRoutes,
                             I: Interactor,
                             P: Presenter,
                             DS: BaseDataStore & NSObject>: VIPViewController<C, I, P, DS>,
                                                            UITableViewDelegate,
                                                            UITableViewDataSource {
    override var isModalDismissableEnabled: Bool {
        return true
    }

    var sections: [AnyHashable] = []
    var sectionRows: [AnyHashable: [Any]] = [:]

    // MARK: LazyUI
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        // this prevents the top offset on tableViews
        let zeroView = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: CGFloat.leastNonzeroMagnitude)))
        tableView.tableHeaderView = zeroView
        tableView.tableFooterView = zeroView
        tableView.estimatedSectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.estimatedRowHeight = CGFloat.leastNormalMagnitude
        tableView.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude

        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude

        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        let topInsetValue = sceneLeftAlignedTitle == nil ? 0 : (Margins.large.rawValue * 2) + 28
        
        view.addSubview(leftAlignedTitleLabel)
        leftAlignedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(topInsetValue)
            make.leading.trailing.equalToSuperview().inset(Margins.large.rawValue)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.contentInset.top = topInsetValue
    }
    
    // MARK: ResponseDisplay
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return sectionRows[section]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return .init(frame: .zero)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return .init(frame: .zero)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, didSelectHeaderIn section: Int) {}

    func tableView(_ tableView: UITableView, didSelectFooterIn section: Int) {}
}
