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
        self.navigationController.setViewControllers([currentViewController!], animated: true)
    }
    
    func getHomeTabBarItems() -> [TabBarItem] {
        return [
            TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(ContactsViewController.self, argument: self)!, title: "Contacts", image: "contacts", position: 0, isSelected: true),
            TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(CallHistoryViewController.self, argument: self)!, title: "Call History", image: "callHistory", position: 1, isSelected: false),
            TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(ChatsViewController.self, argument: self)!, title: "Chats", image: "chats", position: 2, isSelected: false),
            TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(SettingsViewController.self, argument: self)!, title: "Settings", image: "settings", position: 3, isSelected: false)
        ]
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
