//
//  AppAssembly.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Combine
import Swinject

final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        self.assembleCoreDataStack(container)
        self.assembleMainRepository(container)
        self.assembleSSE(container)
        self.assembleWindowManager(container)
        self.assembleHomeViewController(container)
        self.assembleContactsViewController(container)
        self.assembleCallHistoryViewController(container)
        self.assembleAllChatsViewController(container)
        self.assembleSettingsViewController(container)
    }
    
    private func assembleMainRepository(_ container: Container) {
        container.register(NetworkService.self) { r in
            return NetworkService()
        }.inObjectScope(.container)
        
        container.register(DatabaseService.self) { r in
            let coreDataStack = container.resolve(CoreDataStack.self)!
            let userEntityService = UserEntityService(coreDataStack: coreDataStack)
            let chatEntityService = ChatEntityService(coreDataStack: coreDataStack)
            let messageEntityService = MessageEntityService(coreDataStack: coreDataStack)
            let roomEntityService = RoomEntityService(coreDataStack: coreDataStack)
            return DatabaseService(userEntityService: userEntityService, chatEntityService: chatEntityService, messageEntityService: messageEntityService, roomEntityService: roomEntityService, coreDataStack: coreDataStack)
        }.inObjectScope(.container)

        container.register(Repository.self, name: RepositoryType.production.name) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return AppRepository(networkService: networkService, databaseService: databaseService)
        }.inObjectScope(.container)
    }
    
    private func assembleCoreDataStack(_ container: Container) {
        container.register(CoreDataStack.self) { r in
            let coreDataStack = CoreDataStack()
            return coreDataStack
        }.inObjectScope(.container)
    }
    
    private func assembleSSE(_ container: Container) {
        container.register(SSE.self) { (r, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return SSE(repository: repository, coordinator: coordinator)
        }.inObjectScope(.container)
    }
    
    private func assembleWindowManager(_ container: Container) {
        container.register(WindowManager.self) { (r, scene: UIWindowScene) in
            return WindowManager(scene: scene)
        }.inObjectScope(.container)
    }
    
    private func assembleHomeViewController(_ container: Container) {
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return HomeViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator, startParameters: HomeViewController.HomeViewControllerStartConfig) in
            let controller = HomeViewController(viewModel: container.resolve(HomeViewModel.self, argument: coordinator)!,
                                                startConfig: startParameters)
//            controller.viewModel = container.resolve(HomeViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleContactsViewController(_ container: Container) {
        container.register(ContactsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return ContactsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(ContactsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = ContactsViewController()
            controller.viewModel = container.resolve(ContactsViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }

    private func assembleCallHistoryViewController(_ container: Container) {
        container.register(CallHistoryViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CallHistoryViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(CallHistoryViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = CallHistoryViewController()
            controller.viewModel = container.resolve(CallHistoryViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleAllChatsViewController(_ container: Container) {
        container.register(AllChatsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return AllChatsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(AllChatsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = AllChatsViewController()
            controller.viewModel = container.resolve(AllChatsViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleSettingsViewController(_ container: Container) {
        container.register(SettingsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return SettingsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(SettingsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = SettingsViewController()
            controller.viewModel = container.resolve(SettingsViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    
    //      select _____ command option E and change name
    //
//        private func assemble_____ViewController(_ container: Container) {
//            container.register(_____ViewModel.self) { (resolver, coordinator: AppCoordinator) in
//                let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
//                return _____ViewModel(repository: repository, coordinator: coordinator)
//            }.inObjectScope(.transient)
//
//            container.register(_____ViewController.self) { (resolver, coordinator: AppCoordinator) in
//                let controller = _____ViewController()
//                controller.viewModel = container.resolve(_____ViewModel.self, argument: coordinator)
//                return controller
//            }.inObjectScope(.transient)
//        }
    
   
}
