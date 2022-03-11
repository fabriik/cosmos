//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCConfirmEmailDisplayLogic: class {
    // MARK: Display logic functions
    
    func displaySubmitData(viewModel: KYCConfirmEmail.SubmitData.ViewModel)
    func displayResendCode(viewModel: KYCConfirmEmail.ResendCode.ViewModel)
    func displayShouldEnableConfirm(viewModel: KYCConfirmEmail.ShouldEnableConfirm.ViewModel)
    func displayValidateField(viewModel: KYCConfirmEmail.ValidateField.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCConfirmEmailViewController: KYCViewController, KYCConfirmEmailDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCConfirmEmailBusinessLogic?
    var router: (NSObjectProtocol & KYCConfirmEmailRoutingLogic)?
    
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
        let interactor = KYCConfirmEmailInteractor()
        let presenter = KYCConfirmEmailPresenter()
        let router = KYCConfirmEmailRouter()
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
        
        tableView.register(cell: KYCConfirmEmailCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        interactor?.executeShouldResendCode(request: .init())
    }
    
    // MARK: View controller functions
    
    func displaySubmitData(viewModel: KYCConfirmEmail.SubmitData.ViewModel) {
        LoadingView.hide()
        
        router?.showKYCSignInScene()
    }
    
    func displayResendCode(viewModel: KYCConfirmEmail.ResendCode.ViewModel) {
        LoadingView.hide()
    }
    
    func displayShouldEnableConfirm(viewModel: KYCConfirmEmail.ShouldEnableConfirm.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? KYCConfirmEmailCell else { return }
        
        let style: KYCButton.ButtonStyle = viewModel.shouldEnable ? .enabled : .disabled
        cell.changeButtonStyle(with: style)
    }
    
    func displayValidateField(viewModel: KYCConfirmEmail.ValidateField.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? KYCConfirmEmailCell else { return }
        
        cell.changeFieldStyle(isViable: viewModel.isViable)
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
            return getKYCSConfirmEmailFieldsCell(indexPath)
        }
    }
    
    func getKYCSConfirmEmailFieldsCell(_ indexPath: IndexPath) -> KYCConfirmEmailCell {
        guard let cell = tableView.dequeue(cell: KYCConfirmEmailCell.self) else {
            return KYCConfirmEmailCell()
        }
        
        cell.didChangeConfirmationCodeField = { [weak self] text in
            self?.interactor?.executeCheckFieldType(request: .init(text: text,
                                                                   type: .code))
        }
        
        cell.didTapConfirmButton = { [weak self] in
            LoadingView.show()
            
            self?.interactor?.executeSubmitData(request: .init())
        }
        
        cell.didTapResendButton = { [weak self] in
            LoadingView.show()
            
            self?.interactor?.executeResendCode(request: .init())
        }
        
        return cell
    }
}
