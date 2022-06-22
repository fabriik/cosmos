//
//  Coordinator.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

protocol BaseControllable: UIViewController {

    associatedtype CoordinatorType: CoordinatableRoutes
    var coordinator: CoordinatorType? { get set }
}

protocol Coordinatable: CoordinatableRoutes {

    // TODO: should eventually die
    var modalPresenter: ModalPresenter? { get set }
    var childCoordinators: [Coordinatable] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinatable? { get set }

    func childDidFinish(child: Coordinatable)
    func goBack()
    init(navigationController: UINavigationController)
    func start()
}

class BaseCoordinator: NSObject,
                       Coordinatable {

    // TODO: should eventually die
    weak var modalPresenter: ModalPresenter? {
        get {
            guard let modalPresenter = presenter else {
                return parentCoordinator?.modalPresenter
            }

            return modalPresenter
        }
        set {
            presenter = newValue
        }
    }
    
    private weak var presenter: ModalPresenter?
    var parentCoordinator: Coordinatable?
    var childCoordinators: [Coordinatable] = []
    var navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    init(viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        let navigationController = RootNavigationController(rootViewController: viewController)
        self.navigationController = navigationController
    }

    func start() {
        let nvc = RootNavigationController()
        let coordinator: Coordinatable
        if UserDefaults.emailConfirmed {
            coordinator = ProfileCoordinator(navigationController: nvc)
        } else {
            coordinator = RegistrationCoordinator(navigationController: nvc)
        }
        
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        navigationController.show(nvc, sender: nil)
    }

    /// Determines whether the viewcontroller or navigation stack are being dismissed
    func goBack() {
        // if the same coordinator is used in a flow, we dont want to remove it from the parent
        guard navigationController.viewControllers.count < 1 else { return }

        guard navigationController.isBeingDismissed
                || navigationController.presentedViewController?.isBeingDismissed == true
                || navigationController.presentedViewController?.isMovingFromParent == true
                || parentCoordinator?.navigationController == navigationController
        else { return }
        parentCoordinator?.childDidFinish(child: self)
    }

    /// Remove the child coordinator from the stack after iit finnished its flow
    func childDidFinish(child: Coordinatable) {
        childCoordinators.removeAll(where: { $0 === child })
    }

    // only call from coordinator subclasses
    func open<T: BaseControllable>(scene: T.Type,
                                   presentationStyle: UIModalPresentationStyle = .fullScreen,
                                   configure: ((T) -> Void)? = nil) {
        let controller = T()
        controller.coordinator = (self as? T.CoordinatorType)
        configure?(controller)
        navigationController.modalPresentationStyle = presentationStyle
        navigationController.show(controller, sender: nil)
    }

    // only call from coordinator subclasses
    func openModally<C: BaseCoordinator,
                            VC: BaseControllable>(coordinator: C.Type,
                                                  scene: VC.Type,
                                                  presentationStyle: UIModalPresentationStyle = .fullScreen,
                                                  configure: ((VC?) -> Void)? = nil) {
        let controller = VC()
        let nvc = RootNavigationController(rootViewController: controller)
        nvc.modalPresentationStyle = presentationStyle
        nvc.modalPresentationCapturesStatusBarAppearance = true
        
        let coordinator = C(navigationController: nvc)
        controller.coordinator = coordinator as? VC.CoordinatorType
        configure?(controller)

        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        navigationController.show(nvc, sender: nil)
    }
    
    func showBuy() {
        upgradeAccountOrShowPopup { [unowned self] show in
            guard show else { return }
            
            let data = ReservationRequestData()
            ReservationWorker().execute(requestData: data) { [unowned self] reservation, error in
                guard let url = reservation?.url,
                      let code = reservation?.reservation else {
                    // TODO: handle error
                    print("error: \(error?.localizedDescription ?? "UNKNOWN")")
                    return
                }
                
                guard UserDefaults.showBuyAlert else {
                    Store.perform(action: RootModalActions.Present(modal: .buy(url: url, reservationCode: code, currency: nil)))
                    return
                }
                UserDefaults.showBuyAlert = false
                let message = "Fabriik is providing Buy functionality through Wyre, a third-party API provider."
                
                let alert = UIAlertController(title: "Partnership note",
                                              message: message,
                                              preferredStyle: .alert)
                let continueAction = UIAlertAction(title: L10n.Button.continueAction, style: .default) { _ in
                    Store.perform(action: RootModalActions.Present(modal: .buy(url: url, reservationCode: code, currency: nil)))
                }
                
                alert.addAction(continueAction)
                navigationController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showSwap(currencies: [String]) {
        upgradeAccountOrShowPopup { [unowned self] showPopup in
            guard showPopup else { return }
            guard UserDefaults.showSwapAlert else {
                Store.perform(action: RootModalActions.Present(modal: .trade(availibleCurrencies: currencies, amount: 1)))
                return
            }
            UserDefaults.showSwapAlert = false
            let message = "Fabriik is providing Swap functionality through Changelly, a third-party API provider."
            
            let alert = UIAlertController(title: "Partnership note",
                                          message: message,
                                          preferredStyle: .alert)
            let continueAction = UIAlertAction(title: L10n.Button.continueAction, style: .default) { _ in
                Store.perform(action: RootModalActions.Present(modal: .trade(availibleCurrencies: currencies, amount: 1)))
            }
            
            alert.addAction(continueAction)
            navigationController.present(alert, animated: true, completion: nil)
        }
    }
    
    // TODO: really dont know how to name this :S
    // IT prepares the next KYC coordinator OR returns true
    // in which case we show 3rd party popup or continue to buy/swap
    private func upgradeAccountOrShowPopup(completion: ((Bool) -> Void)?) {
        UserManager.shared.refresh { [unowned self] _ in
            var coordinator: Coordinatable?
            if UserDefaults.kycSessionKeyValue.isEmpty
                || !UserDefaults.emailConfirmed {
                coordinator = RegistrationCoordinator(navigationController: RootNavigationController())
            } else if UserManager.shared.profile?.status.canBuyTrade == false {
                coordinator = KYCCoordinator(navigationController: RootNavigationController())
            }
            
            guard let coordinator = coordinator else {
                completion?(true)
                return
            }

            coordinator.start()
            coordinator.parentCoordinator = self
            childCoordinators.append(coordinator)
            navigationController.show(coordinator.navigationController, sender: nil)
            completion?(false)
        }
    }

    func showMessage(with error: Error? = nil, model: InfoViewModel?, configuration: InfoViewConfiguration?) {
        guard (error as? SessioExpiredError) == nil else {
            openModally(coordinator: RegistrationCoordinator.self, scene: Scenes.RegistrationConfirmation)
            return
        }
        
        let notification = FEInfoView()
        notification.setupCustomMargins(all: .large)
        notification.configure(with: configuration)
        notification.setup(with: model)
        guard let superview = navigationController.topViewController?.view else {
            return
        }
        superview.addSubview(notification)
        notification.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(Margins.medium.rawValue)
            make.trailing.equalToSuperview().offset(-Margins.medium.rawValue)
        }
        notification.layoutIfNeeded()
        notification.alpha = 0
            
        UIView.animate(withDuration: Presets.Animation.duration) {
            notification.alpha = 1
        }
    }
    
    func hideMessage(_ view: UIView) {}

    func goBack(completion: (() -> Void)? = nil) {
        guard parentCoordinator != nil,
              parentCoordinator?.navigationController != navigationController else {
            navigationController.popViewController(animated: true)
            return
        }
        navigationController.dismiss(animated: true) {
            completion?()
        }
        parentCoordinator?.childDidFinish(child: self)
    }
    
    func showUnderConstruction(_ feat: String) {
        // TODO: navigate on
        showPopup(with: .init(title: .text("Under construction"),
                              body: "The \(feat.uppercased()) functionality is being developed for You by the awesome Fabriik team. Stay tuned!"))
    }
    
    func showOverlay(with viewModel: TransparentViewModel, completion: (() -> Void)? = nil) {
        guard let parent = navigationController.view
        else { return }
        
        let view = TransparentView()
        view.configure(with: .init())
        view.setup(with: viewModel)
        view.didHide = completion
        
        parent.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        view.show()
    }
    
    func hideOverlay() {
        guard let view = navigationController.view.subviews.first(where: { $0 is TransparentView }) as? TransparentView else { return }
        view.hide()
    }
}
