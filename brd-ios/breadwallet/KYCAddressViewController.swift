// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCAddressDisplayLogic: class {
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
        
        tableView.register(cell: KYCProgressCell.self)
        tableView.register(cell: KYCAddressFieldsCell.self)
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
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? KYCAddressFieldsCell else { return }
        
        cell.setup(with: .init(country: viewModel.viewModel.country,
                               zipCode: nil,
                               address: nil,
                               apartment: nil,
                               state: viewModel.viewModel.state))
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
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> KYCProgressCell {
        guard let cell = tableView.dequeue(cell: KYCProgressCell.self) else {
            return KYCProgressCell()
        }
        
        cell.setValues(text: "ADDRESS", progress: .address)
        
        return cell
    }
    
    func getKYCAddressFieldsCell(_ indexPath: IndexPath) -> KYCAddressFieldsCell {
        guard let cell = tableView.dequeue(cell: KYCAddressFieldsCell.self) else {
            return KYCAddressFieldsCell()
        }
        
        cell.didTapCountryPicker = { [weak self] in
            self?.interactor?.executeGetDataForPickerView(request: .init(type: .country))
        }
        
        cell.didChangeZipCodeField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .zipCode))
        }
        
        cell.didChangeAddressField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .address))
        }
        
        cell.didChangeApartmentField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .apartment))
        }
        
        cell.didChangeCityField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .city))
        }
        
        cell.didTapStatePicker = { [weak self] in
            self?.interactor?.executeGetDataForPickerView(request: .init(type: .state))
        }
        
        cell.didTapNextButton = { [weak self] in
            self?.router?.showKYCPersonalInfoScene()
        }
        
        return cell
    }
}
