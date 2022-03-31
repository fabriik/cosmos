// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCPersonalInfoDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displaySetDateAndTaxID(viewModel: KYCPersonalInfo.SetDateAndTaxID.ViewModel)
    func displayGetDataForPickerView(viewModel: KYCPersonalInfo.GetDataForPickerView.ViewModel)
    func displaySetPickerValue(viewModel: KYCPersonalInfo.SetPickerValue.ViewModel)
}

class KYCPersonalInfoViewController: KYCViewController, KYCPersonalInfoDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCPersonalInfoBusinessLogic?
    var router: (NSObjectProtocol & KYCPersonalInfoRoutingLogic)?
    
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
        let interactor = KYCPersonalInfoInteractor()
        let presenter = KYCPersonalInfoPresenter()
        let router = KYCPersonalInfoRouter()
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
    
    var didSetDateAndTaxId: ((_ date: String, _ taxId: String) -> Void)?
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CellWrapperView<KYCProgressView>.self)
        tableView.register(CellWrapperView<KYCPersonalInfoView>.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    func displayGetDataForPickerView(viewModel: KYCPersonalInfo.GetDataForPickerView.ViewModel) {
        tableView.endEditing(true)
        
        DatePickerViewController.show(on: self,
                                      sourceView: view,
                                      title: nil,
                                      date: viewModel.date,
                                      minimumDate: Date.distantPast,
                                      maximumDate: Date.distantFuture) { [weak self] date in
            self?.interactor?.executeCheckFieldPickerIndex(request: .init(selectedDate: date,
                                                                          type: viewModel.type))
        }
    }
    
    func displaySetPickerValue(viewModel: KYCPersonalInfo.SetPickerValue.ViewModel) {
        guard let index = sections.firstIndex(of: .fields) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? CellWrapperView<KYCPersonalInfoView> else { return }
        
        cell.setup { view in
            view.setup(with: .init(date: viewModel.viewModel.date,
                                   taxIdNumber: nil))
        }
    }
    
    func displaySetDateAndTaxID(viewModel: KYCPersonalInfo.SetDateAndTaxID.ViewModel) {
        didSetDateAndTaxId?(viewModel.date, viewModel.taxIdNumber)
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
            return getKYCPersonalInfoCell(indexPath)
            
        }
    }
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCProgressView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.setup(with: .init(text: "PERSONAL INFO", progress: .personalInfo))
        }
        
        return cell
    }
    
    func getKYCPersonalInfoCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CellWrapperView<KYCPersonalInfoView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.didTapDateOfBirthField = { [weak self] in
                self?.interactor?.executeGetDataForPickerView(request: .init(type: .date))
            }
            
            view.didChangeTaxIdNumberField = { [weak self] text in
                self?.interactor?.executeCheckFieldType(request: .init(text: text, type: .taxIdNumber))
            }
            
            view.didTapNextButton = { [weak self] in
                self?.view.endEditing(true)
                
                LoadingView.show()
                
                let kycAddressVC = self?.navigationController?.children.first(where: { $0 is KYCAddressViewController })
                (kycAddressVC as? KYCAddressViewController)?.didSubmitData = { [weak self] in
                    LoadingView.hide()
                    
                    self?.router?.showKYCUploadScene()
                }
                
                self?.interactor?.executeSetDateAndTaxID(request: .init())
            }
        }
        
        return cell
    }
}
