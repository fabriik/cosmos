//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainDisplayLogic: AnyObject {
    // MARK: Display logic functions
}

class SwapMainViewController: UIViewController, SwapMainDisplayLogic {
    var interactor: SwapMainBusinessLogic?
    var router: (NSObjectProtocol & SwapMainRoutingLogic)?
    
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
        let interactor = SwapMainInteractor()
        let presenter = SwapMainPresenter()
        let router = SwapMainRouter()
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
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = SwapPickCurrencyViewController()
        let navController = SwapNavigationController(rootViewController: vc)
        
        if #available(iOS 14.0, *) {
            navController.isModalInPresentation = true
        } else {
            navController.modalPresentationStyle = .overFullScreen
        }
        
        present(navController, animated: true, completion: nil)
        
        view.backgroundColor = UIColor(red: 51.0/255.0, green: 32.0/255.0, blue: 69.0/255.0, alpha: 1.0)
        
        localize()
        fetch()
    }
    
    func localize() {
        title = ""
    }
    
    func fetch() {
        
    }
    
    // MARK: View controller functions
    
}
