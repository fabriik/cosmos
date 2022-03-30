// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCAddressDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayGetDataForPickerView(viewModel: KYCAddress.GetDataForPickerView.ViewModel)
    func displaySetPickerValue(viewModel: KYCAddress.SetPickerValue.ViewModel)
    func displaySubmitData(viewModel: KYCAddress.SubmitData.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCAddressViewController: KYCViewController, KYCAddressDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCAddressBusinessLogic?
    var router: (NSObjectProtocol & KYCAddressRoutingLogic)?
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = KYCAddressInteractor()
        let presenter = KYCAddressPresenter()
        let router = KYCAddressRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: - Properties
    enum Section {
        case progress
        case fields
    }
    
    private let sections: [Section] = [
        .progress,
        .fields
    ]
    
    var didSubmitData: (() -> Void)?
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<KYCProgressView>.self)
        tableView.register(CellWrapperView<KYCAddressFieldsView>.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    func displayGetDataForPickerView(viewModel: KYCAddress.GetDataForPickerView.ViewModel) {
        tableView.endEditing(true)
        
        PickerViewViewController.show(on: self,
                                      values: [viewModel.pickerValues],
                                      selection: viewModel.index) { [weak self] _, _, selectedIndex, _ in
            self?.interactor?.executeCheckFieldPickerIndex(request: .init(index: selectedIndex,
                                                                          pickerValues: viewModel.pickerValues,
                                                                          fieldValues: viewModel.fieldValues,
                                                                          type: viewModel.type))
        }
    }
    
    func displaySetPickerValue(viewModel: KYCAddress.SetPickerValue.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCAddressFieldsView> else { return }
        
        cell.setup { view in
            view.setup(with: .init(country: viewModel.viewModel.country,
                                   zipCode: nil,
                                   address: nil,
                                   apartment: nil,
                                   state: viewModel.viewModel.state))
        }
    }
    
    func displaySubmitData(viewModel: KYCAddress.SubmitData.ViewModel) {
        didSubmitData?()
    }
    
    func displayError(viewModel: GenericModels.Error.ViewModel) {
        LoadingView.hide()
        
        let alert = UIAlertController(style: .alert, message: viewModel.error)
        alert.addAction(title: "OK", style: .cancel)
        alert.show(on: self)
    }
    
    func submitData() {
        interactor?.executeSubmitData(request: .init())
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .progress:
            return getKYCProgressCell(indexPath)
            
        case .fields:
            return getKYCAddressFieldsCell(indexPath)
            
        }
    }
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCProgressView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.setup(with: .init(text: "ADDRESS", progress: .address))
        }
        
        return cell
    }
    
    func getKYCAddressFieldsCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCAddressFieldsView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didTapCountryPicker = { [weak self] in
                self?.interactor?.executeGetDataForPickerView(request: .init(type: .country))
            }
            
            view.didChangeZipCodeField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .zipCode))
            }
            
            view.didChangeAddressField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .address))
            }
            
            view.didChangeApartmentField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .apartment))
            }
            
            view.didChangeCityField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .city))
            }
            
            view.didTapStatePicker = { [weak self] in
                self?.interactor?.executeGetDataForPickerView(request: .init(type: .state))
            }
            
            view.didTapNextButton = { [weak self] in
                self?.view.endEditing(true)
                
                self?.router?.showKYCPersonalInfoScene()
            }
        }
        
        return cell
    }
}
