// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCResetPasswordDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displaySubmitData(viewModel: KYCResetPassword.SubmitData.ViewModel)
    func displayShouldEnableConfirm(viewModel: KYCResetPassword.ShouldEnableConfirm.ViewModel)
    func displayValidateField(viewModel: KYCResetPassword.ValidateField.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCResetPasswordViewController: KYCViewController, KYCResetPasswordDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCResetPasswordBusinessLogic?
    var router: (NSObjectProtocol & KYCResetPasswordRoutingLogic)?
    
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
        let interactor = KYCResetPasswordInteractor()
        let presenter = KYCResetPasswordPresenter()
        let router = KYCResetPasswordRouter()
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
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<KYCProgressView>.self)
        tableView.register(CellWrapperView<KYCResetPasswordView>.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    func displaySubmitData(viewModel: KYCResetPassword.SubmitData.ViewModel) {
        LoadingView.hide()
        
        router?.showKResetPasswordSuccessScene()
    }
    
    func displayShouldEnableConfirm(viewModel: KYCResetPassword.ShouldEnableConfirm.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCResetPasswordView> else { return }
        
        cell.setup { view in
            let style: SimpleButton.ButtonStyle = viewModel.shouldEnable ? .kycEnabled : .kycDisabled
            view.changeButtonStyle(with: style)
        }
    }
    
    func displayValidateField(viewModel: KYCResetPassword.ValidateField.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCResetPasswordView> else { return }
        
        cell.setup { view in
            view.changeFieldStyle(isViable: viewModel.isViable,
                                  for: viewModel.type,
                                  isFieldEmpty: viewModel.isFieldEmpty)
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
        case .progress:
            return getKYCProgressCell(indexPath)
            
        case .fields:
            return getKYCResetPasswordFieldsCell(indexPath)
            
        }
    }
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCProgressView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.setup(with: .init(text: "PASSWORD RECOVERY",
                                   stepCount: KYCProgressView.ForgotPasswordProgress.allCases.count,
                                   currentStep: KYCProgressView.ForgotPasswordProgress.newPassword.rawValue))
        }
        
        return cell
    }
    
    func getKYCResetPasswordFieldsCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCResetPasswordView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didChangeCodeField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text,
                                                                       type: .recoveryCode))
            }
            
            view.didChangePasswordField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text,
                                                                       type: .password))
            }
            
            view.didChangePasswordRepeatField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text,
                                                                       type: .passwordRepeat))
            }
            
            view.didTapConfirmButton = { [weak self] in
                self?.view.endEditing(true)
                
                LoadingView.show()
                
                self?.interactor?.executeSubmitData(request: .init())
            }
        }
        
        return cell
    }
}
