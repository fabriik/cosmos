//
//  KYCBasicViewController.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicViewController: BaseTableViewController<KYCCoordinator,
                                  KYCBasicInteractor,
                                  KYCBasicPresenter,
                                  KYCBasicStore>,
                                  KYCBasicResponseDisplays {
    typealias Models = KYCBasicModels
    
    override var sceneTitle: String? {
        // TODO: localize
        return "Personal Information"
    }
    private var isValid = false

    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.register(WrapperTableViewCell<NameView>.self)
        tableView.register(WrapperTableViewCell<DateView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .name:
            cell = self.tableView(tableView, nameCellForRowAt: indexPath)
            
        case .country:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .birthdate:
            cell = self.tableView(tableView, dateCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .small)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, nameCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<NameView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? NameViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.contentSizeChanged = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            view.valueChanged = { [weak self] first, last in
                self?.interactor?.nameSet(viewAction: .init(first: first, last: last))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, dateCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<DateView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? DateViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.valueChanged = { [weak self] date in
                self?.interactor?.birthDateSet(viewAction: .init(date: date))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, textFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? TextFieldModel,
              let cell: WrapperTableViewCell<FETextField> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.TextField.two)
            view.setup(with: model)
            view.contentSizeChanged = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            view.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard var model = sectionRows[section]?[indexPath.row] as? ButtonViewModel,
              let cell: WrapperTableViewCell<FEButton> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        model.enabled = isValid
        cell.setup { view in
            view.configure(with: Presets.Button.primary)
            view.setup(with: model)
            view.setupCustomMargins(vertical: .large, horizontal: .large)
            view.snp.makeConstraints { make in
                // TODO: constants for view heights
                make.height.equalTo(48)
            }
            view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: move to cell tap callback
        switch sections[indexPath.section] as? Models.Section {
        case .country:
            guard let index = sections.firstIndex(of: Models.Section.country),
                  let cell = tableView.cellForRow(at: .init(row: 0, section: index)) as? WrapperTableViewCell<FETextField> else {
                return
            }
            
            cell.wrappedView.animateTo(state: .selected)
            coordinator?.showCountrySelector { [weak self] code in
                cell.wrappedView.animateTo(state: .normal, withAnimation: false)
                self?.interactor?.countrySelected(viewAction: .init(code: code))
            }
            
        default:
            return
        }
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        view.endEditing(true)
        interactor?.submit(vieAction: .init())
    }

    // MARK: - KYCBasicResponseDisplay
    func displayValidate(responseDisplay: KYCBasicModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Section.confirm),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else {
            return
        }
        cell.wrappedView.isEnabled = responseDisplay.isValid
    }
    
    func displaySubmit(responseDisplay: KYCBasicModels.Submit.ResponseDisplay) {
        guard responseDisplay.error == nil else {
            // TODO: handle error
            return
        }
        
        coordinator?.showOverlay(with: .success) { [weak self] in
            self?.coordinator?.goBack()
        }
    }
    
    // MARK: - Additional Helpers
}
