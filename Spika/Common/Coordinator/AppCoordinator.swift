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
//        presentEnterNumberScreen()
//        presentVerifyCodeScreen(number: "123456", deviceId: "111111")
        presentHomeScreen()
//        presentEnterUsernameScreen()
    }
    
    func presentEnterNumberScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterNumberViewController.self, argument: self)!
        self.currentViewController = viewController
        self.navigationController.setViewControllers([currentViewController!], animated: true)
    }
    
    func presentVerifyCodeScreen(number: String, deviceId: String) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterVerifyCodeViewController.self, arguments: self, number, deviceId)!
        self.currentViewController = viewController
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCountryPicker(delegate: CountryPickerViewDelegate) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(CountryPickerViewController.self, arguments: self, delegate)!
        self.currentViewController?.present(viewController, animated: true)
    }
    
    func presentEnterUsernameScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterUsernameViewController.self, argument: self)!
        self.currentViewController = viewController
        self.navigationController.setViewControllers([viewController], animated: true)
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
