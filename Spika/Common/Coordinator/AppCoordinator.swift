//
//  AppCoordinator.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Swinject

class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var currentViewController: UIViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        presentHomeScreen()
    }
    
    func presentHomeScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(HomeViewController.self, argument: self)!
        self.currentViewController = viewController
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentDetailsScreen(id: Int) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(DetailsViewController.self, arguments: self, id)!
        self.currentViewController = viewController
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func popTopViewController() {
        self.navigationController.popViewController(animated: true)
        self.currentViewController = self.navigationController.topViewController
    }
    
}
