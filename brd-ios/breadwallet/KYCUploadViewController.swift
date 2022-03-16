// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCUploadDisplayLogic: AnyObject {
    // MARK: Display logic functions
    
    func displaySaveImage(viewModel: KYCUpload.SaveImages.ViewModel)
    func displayError(viewModel: GenericModels.Error.ViewModel)
}

class KYCUploadViewController: KYCViewController, KYCUploadDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: KYCUploadBusinessLogic?
    var router: (NSObjectProtocol & KYCUploadRoutingLogic)?
    
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
        let interactor = KYCUploadInteractor()
        let presenter = KYCUploadPresenter()
        let router = KYCUploadRouter()
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
        case text
        case camera
    }
    
    enum Step {
        case idFront
        case idBack
        case idSelfie
        
        var title: String {
            switch self {
            case .idFront:
                return "ID UPLOAD - FRONT"
                
            case .idBack:
                return "ID UPLOAD - BACK"
                
            case .idSelfie:
                return "ID VERIFICATION"
                
            }
        }
        
        var subtitle: String {
            switch self {
            case .idFront:
                return "Take a photo of the front of your driver’s lisence or government issued ID.\n\nMake sure to take a clear and readable photo to avoid delays or failed verification."
                
            case .idBack:
                return "Take a photo of the back of your driver’s lisence or government issued ID.\n\nMake sure to take a clear and readable photo to avoid delays or failed verification."
                
            case .idSelfie:
                return "Take a quick face photo to confirm you are the person on your ID.\n\nMake sure your face is clear and well lit to avoid delays or failed verification."
                
            }
        }
    }
    
    private let sections: [Section] = [
        .progress,
        .text,
        .camera
    ]
    
    private var step: Step = .idFront
    private var shouldShowKYCCompleteScene = false
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cell: KYCProgressCell.self)
        tableView.register(cell: KYCCenteredTextCell.self)
        tableView.register(cell: KYCCameraCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: View controller functions
    
    func displaySaveImage(viewModel: KYCUpload.SaveImages.ViewModel) {
        LoadingView.hide()
        
        guard shouldShowKYCCompleteScene else { return }
        router?.showKYCCompleteScene()
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
            
        case .text:
            return getKYCCenteredTextCell(indexPath)
            
        case .camera:
            return getKYCCameraCell(indexPath)
            
        }
    }
    
    func getKYCProgressCell(_ indexPath: IndexPath) -> KYCProgressCell {
        guard let cell = tableView.dequeue(cell: KYCProgressCell.self) else {
            return KYCProgressCell()
        }
        
        cell.setValues(text: step.title, progress: .idFront)
        
        return cell
    }
    
    func getKYCCenteredTextCell(_ indexPath: IndexPath) -> KYCCenteredTextCell {
        guard let cell = tableView.dequeue(cell: KYCCenteredTextCell.self) else {
            return KYCCenteredTextCell()
        }
        
        cell.setText(step.subtitle)
        
        return cell
    }
    
    func getKYCCameraCell(_ indexPath: IndexPath) -> KYCCameraCell {
        guard let cell = tableView.dequeue(cell: KYCCameraCell.self) else {
            return KYCCameraCell()
        }
        
        cell.didTapNextButton = { [weak self] image in
            guard let self = self else { return }
            
            cell.retryAction()
            cell.changeCameraControlState(isEnabled: true)
            
            switch self.step {
            case .idFront:
                self.step = .idBack
                self.interactor?.setImage(request: .init(step: .idFront, image: image))
                
            case .idBack:
                LoadingView.show()
                
                self.step = .idSelfie
                cell.activateSelfieCamera()
                self.interactor?.setImage(request: .init(step: .idBack, image: image))
                self.interactor?.saveImage(request: .init(step: .idBack))
                
            case .idSelfie:
                LoadingView.show()
                
                cell.stopCamera()
                self.shouldShowKYCCompleteScene = true
                self.interactor?.setImage(request: .init(step: .idSelfie, image: image))
                self.interactor?.saveImage(request: .init(step: .idSelfie))
                
            }
            
            guard let progress = self.sections.firstIndex(of: .progress),
                    let text = self.sections.firstIndex(of: .text) else { return }
            self.tableView.reloadSections([progress, text], with: .fade)
            
        }
        
        return cell
    }
}
