// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCSignUpDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayGetDataForPickerView(viewModel: KYCSignUp.GetDataForPickerView.ViewModel)
    func displaySetPickerValue(viewModel: KYCSignUp.SetPickerValue.ViewModel)
    func displaySubmitData(viewModel: KYCSignUp.SubmitData.ViewModel)
    func displayShouldEnableSubmit(viewModel: KYCSignUp.ShouldEnableSubmit.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCSignUpViewController: KYCViewController, KYCSignUpDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCSignUpBusinessLogic?
    var router: (NSObjectProtocol & KYCSignUpRoutingLogic)?
    
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
        let interactor = KYCSignUpInteractor()
        let presenter = KYCSignUpPresenter()
        let router = KYCSignUpRouter()
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
        case fields
    }
    
    private let sections: [Section] = [
        .fields
    ]
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cell: KYCSignUpCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    func displayGetDataForPickerView(viewModel: KYCSignUp.GetDataForPickerView.ViewModel) {
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
    
    func displaySetPickerValue(viewModel: KYCSignUp.SetPickerValue.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? KYCSignUpCell else { return }
        
        cell.setup(with: .init(firstName: nil,
                               lastName: nil,
                               email: nil,
                               phonePrefix: viewModel.viewModel.phonePrefix,
                               phoneNumber: nil,
                               password: nil,
                               tickBox: nil))
    }
    
    func displayShouldEnableSubmit(viewModel: KYCSignUp.ShouldEnableSubmit.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? KYCSignUpCell else { return }
        
        let style: KYCButton.ButtonStyle = viewModel.shouldEnable ? .enabled : .disabled
        cell.changeButtonStyle(with: style)
    }
    
    func displaySubmitData(viewModel: KYCSignUp.SubmitData.ViewModel) {
        LoadingView.hide()
        
        router?.showKYCConfirmEmailScene()
    }
    
    func displayError(viewModel: GenericModels.Error.ViewModel) {
        LoadingView.hide()
        
        let alert = UIAlertController(style: .alert, message: viewModel.error)
        alert.addAction(title: "OK", style: .cancel)
        alert.show(on: self)
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
        case .fields:
            return getKYCSignUpFieldsCell(indexPath)
            
        }
    }
    
    func getKYCSignUpFieldsCell(_ indexPath: IndexPath) -> KYCSignUpCell {
        guard let cell = tableView.dequeue(cell: KYCSignUpCell.self) else {
            return KYCSignUpCell()
        }
        
        cell.didChangeFirstNameField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .firstName))
        }
        
        cell.didChangeLastNameField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .lastName))
        }
        
        cell.didChangeEmailField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .email))
        }
        
        cell.didTapPhonePrefixField = { [weak self] in
            self?.interactor?.executeGetDataForPickerView(request: .init(type: .phonePrefix))
        }
        
        cell.didChangePhoneNumberField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .phoneNumber))
        }
        
        cell.didChangePasswordField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .password))
        }
        
        cell.didTickPrivacyPolicy = { [weak self] tickStatus in
            self?.interactor?.executeCheckTickBox(request: .init(tickBox: tickStatus, type: .tickBox))
        }
        
        cell.didTapNextButton = { [weak self] in
            self?.view.endEditing(true)
            
            LoadingView.show()
            
            self?.interactor?.executeSubmitData(request: .init())
        }
        
        return cell
    }
}
