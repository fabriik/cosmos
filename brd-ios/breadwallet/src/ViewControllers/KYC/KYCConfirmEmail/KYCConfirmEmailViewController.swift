//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCConfirmEmailDisplayLogic: AnyObject {
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
        
        tableView.register(CellWrapperView<KYCConfirmEmailView>.self)
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
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCConfirmEmailView> else { return }
        
        cell.setup { view in
            let style: SimpleButton.ButtonStyle = viewModel.shouldEnable ? .kycEnabled : .kycDisabled
            view.changeButtonStyle(with: style)
        }
    }
    
    func displayValidateField(viewModel: KYCConfirmEmail.ValidateField.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCConfirmEmailView> else { return }
        
        cell.setup { view in
            view.changeFieldStyle(isViable: viewModel.isViable)
        }
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
            return getKYCConfirmEmailFieldsCell(indexPath)
        }
    }
    
    func getKYCConfirmEmailFieldsCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCConfirmEmailView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didChangeConfirmationCodeField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text,
                                                                       type: .code))
            }
            
            view.didTapConfirmButton = { [weak self] in
                self?.view.endEditing(true)
                
                LoadingView.show()
                
                self?.interactor?.executeSubmitData(request: .init())
            }
            
            view.didTapResendButton = { [weak self] in
                self?.view.endEditing(true)
                
                LoadingView.show()
                
                self?.interactor?.executeResendCode(request: .init())
            }
        }
        
        return cell
    }
}
