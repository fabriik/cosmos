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

    var parentCoordinator: Coordinatable?
    var childCoordinators: [Coordinatable] = []
    var navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    init(viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
    }

    func start() {}

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
        let nvc = UINavigationController(rootViewController: controller)
        nvc.modalPresentationStyle = presentationStyle

        let coordinator = C(navigationController: nvc)
        controller.coordinator = coordinator as? VC.CoordinatorType
        configure?(controller)

        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        navigationController.show(nvc, sender: nil)
    }

    func showAlertView(with model: AlertViewModel?, config: AlertConfiguration?) {}
    func showNotification(with configuration: NotificationConfiguration) {}
    func hideNotification(_ view: UIView) {}

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
}
