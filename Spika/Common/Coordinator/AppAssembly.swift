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

        container.register(AppRepository.self) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return AppRepository(networkService: networkService, databaseService: databaseService)
        }.inObjectScope(.container)
    }
    
    private func assembleHomeViewController(_ container: Container) {
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(AppRepository.self)!
            return HomeViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = HomeViewController()
            controller.viewModel = container.resolve(HomeViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleDetailsViewController(_ container: Container) {
        container.register(DetailsViewModel.self) { (resolver, coordinator: AppCoordinator, id: Int) in
            let repository = container.resolve(AppRepository.self)!
            return DetailsViewModel(repository: repository, coordinator: coordinator, id: id)
        }.inObjectScope(.transient)
        
        container.register(DetailsViewController.self) { (resolver, coordinator: AppCoordinator, id: Int) in
            let controller = DetailsViewController()
            controller.viewModel = container.resolve(DetailsViewModel.self, arguments: coordinator, id)
            return controller
        }.inObjectScope(.transient)
    }
    
}
