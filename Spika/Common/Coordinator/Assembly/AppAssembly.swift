//
//  AppAssembly.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Swinject

final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        self.assembleMainRepository(container)
        self.assembleHomeViewController(container)
        self.assembleDetailsViewController(container)
        self.assembleContactsViewController(container)
        self.assembleCallHistoryViewController(container)
        self.assembleChatsViewController(container)
        self.assembleSettingsViewController(container)
    }
    
    private func assembleMainRepository(_ container: Container) {
        container.register(NetworkService.self) { r in
            return NetworkService()
        }.inObjectScope(.container)
        
        container.register(DatabaseService.self) { r in
            let userEntityService = UserEntityService()
            let chatEntityService = ChatEntityService()
            let messageEntityService = MessageEntityService()
            return DatabaseService(userEntityService: userEntityService, chatEntityService: chatEntityService, messageEntityService: messageEntityService)
        }.inObjectScope(.container)

        container.register(Repository.self, name: RepositoryType.production.name) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return AppRepository(networkService: networkService, databaseService: databaseService)
        }.inObjectScope(.container)
    }
    
    private func assembleHomeViewController(_ container: Container) {
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return HomeViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = HomeViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            controller.viewModel = container.resolve(HomeViewModel.self, argument: coordinator)
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
    
    private func assembleChatsViewController(_ container: Container) {
        container.register(ChatsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return ChatsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(ChatsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = ChatsViewController()
            controller.viewModel = container.resolve(ChatsViewModel.self, argument: coordinator)
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
    
    private func assembleDetailsViewController(_ container: Container) {
        container.register(DetailsViewModel.self) { (resolver, coordinator: AppCoordinator, id: Int) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return DetailsViewModel(repository: repository, coordinator: coordinator, id: id)
        }.inObjectScope(.transient)
        
        container.register(DetailsViewController.self) { (resolver, coordinator: AppCoordinator, id: Int) in
            let controller = DetailsViewController()
            controller.viewModel = container.resolve(DetailsViewModel.self, arguments: coordinator, id)
            return controller
        }.inObjectScope(.transient)
    }
    
}
