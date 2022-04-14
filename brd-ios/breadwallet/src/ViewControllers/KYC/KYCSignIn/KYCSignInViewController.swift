//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCSignInDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displayShouldEnableSubmit(viewModel: KYCSignIn.ShouldEnableSubmit.ViewModel)
    func displaySignIn(viewModel: KYCSignIn.SubmitData.ViewModel)
    func displayConfirmEmail(viewModel: KYCSignIn.ConfirmEmail.ViewModel)
    func displayValidateField(viewModel: KYCSignIn.ValidateField.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCSignInViewController: KYCViewController, KYCSignInDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCSignInBusinessLogic?
    var router: (NSObjectProtocol & KYCSignInRoutingLogic)?
    
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
        let interactor = KYCSignInInteractor()
        let presenter = KYCSignInPresenter()
        let router = KYCSignInRouter()
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
        
        tableView.register(CellWrapperView<KYCSignInView>.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        let dismissFlowButton = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissFlow))
        navigationItem.leftBarButtonItem = dismissFlowButton
    }
    
    @objc private func dismissFlow() {
        router?.dismissFlow()
    }
    
    // MARK: View controller functions
    
    func displayShouldEnableSubmit(viewModel: KYCSignIn.ShouldEnableSubmit.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCSignInView> else { return }
        
        cell.setup { view in
            let style: SimpleButton.ButtonStyle = viewModel.shouldEnable ? .kycEnabled : .kycDisabled
            view.changeButtonStyle(with: style)
        }
    }
    
    func displayConfirmEmail(viewModel: KYCSignIn.ConfirmEmail.ViewModel) {
        LoadingView.hide()
        
        router?.showKYCConfirmEmailScene()
    }
    
    func displaySignIn(viewModel: KYCSignIn.SubmitData.ViewModel) {
        LoadingView.hide()
        
        router?.showKYCTutorialScene()
    }
    
    func displayValidateField(viewModel: KYCSignIn.ValidateField.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCSignInView> else { return }
        
        cell.setup { view in
            view.changeFieldStyle(isViable: viewModel.isViable,
                                  isFieldEmpty: viewModel.isFieldEmpty,
                                  for: viewModel.type)
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
            return getKYCSignInFieldsCell(indexPath)
            
        }
    }
    
    func getKYCSignInFieldsCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCSignInView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didChangeEmailField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .email))
            }
            
            view.didChangePasswordField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .password))
            }
            
            view.didTapForgotPasswordButton = { [weak self] in
                self?.router?.showKYCForgotPasswordScene()
            }
            
            view.didTapNextButton = { [weak self] in
                self?.view.endEditing(true)
                
                LoadingView.show()
                
                self?.interactor?.executeSignIn(request: .init())
            }
            
            view.didTapSignUpButton = { [weak self] in
                self?.view.endEditing(true)
                
                self?.router?.showKYCSignUpScene()
            }
        }
        
        return cell
    }
}
