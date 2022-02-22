//
//  TestAssembly.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Swinject

class TestAssembly: Assembly {
    func assemble(container: Container) {
        assembleTestRepository(container)
        assembleHomeViewModel(container)
        assembleContactsViewModel(container)
        assembleChatsViewModel(container)
        assembleCallHistoryViewModel(container)
        assembleSettingsViewModel(container)
    }
    
    private func assembleTestRepository(_ container: Container) {
        container.register(NetworkService.self) { r in
            return NetworkService()
        }.inObjectScope(.container)
        
        container.register(DatabaseService.self) { r in
            let userEntityService = UserEntityService()
            let chatEntityService = ChatEntityService()
            let messageEntityService = MessageEntityService()
            return DatabaseService(userEntityService: userEntityService, chatEntityService: chatEntityService, messageEntityService: messageEntityService)
        }.inObjectScope(.container)

        container.register(Repository.self, name: RepositoryType.test.name) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return TestRepository(networkService: networkService, databaseService: databaseService)
        }.inObjectScope(.container)
    }
    
    private func assembleHomeViewModel(_ container: Container) {
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator, repositoryType: RepositoryType) in
            let repository = container.resolve(Repository.self, name: repositoryType.name)!
            return HomeViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
    }
    
    private func assembleContactsViewModel(_ container: Container) {
        container.register(ContactsViewModel.self) { (resolver, coordinator: AppCoordinator, repositoryType: RepositoryType) in
            let repository = container.resolve(Repository.self, name: repositoryType.name)!
            return ContactsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
    }
    
    private func assembleCallHistoryViewModel(_ container: Container) {
        container.register(CallHistoryViewModel.self) { (resolver, coordinator: AppCoordinator, repositoryType: RepositoryType) in
            let repository = container.resolve(Repository.self, name: repositoryType.name)!
            return CallHistoryViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
    }
    
    private func assembleChatsViewModel(_ container: Container) {
        container.register(AllChatsViewModel.self) { (resolver, coordinator: AppCoordinator, repositoryType: RepositoryType) in
            let repository = container.resolve(Repository.self, name: repositoryType.name)!
            return AllChatsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
    }
    
    private func assembleSettingsViewModel(_ container: Container) {
        container.register(SettingsViewModel.self) { (resolver, coordinator: AppCoordinator, repositoryType: RepositoryType) in
            let repository = container.resolve(Repository.self, name: repositoryType.name)!
            return SettingsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
    }
}
