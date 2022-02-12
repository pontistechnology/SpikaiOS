//
//  ContactsAssembly.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Swinject

class ContactsAssembly: Assembly {
    func assemble(container: Container) {
        assembleDetailsViewController(container)
        assembleSharedViewController(container)
        assembleChatSearchViewController(container)
        assembleNotesViewController(container)
        assembleFavoritesViewController(container)
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
    
    private func assembleSharedViewController(_ container: Container) {
        container.register(SharedViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return SharedViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(SharedViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = SharedViewController()
            controller.viewModel = container.resolve(SharedViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleFavoritesViewController(_ container: Container) {
        container.register(FavoritesViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return FavoritesViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(FavoritesViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = FavoritesViewController()
            controller.viewModel = container.resolve(FavoritesViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleNotesViewController(_ container: Container) {
        container.register(NotesViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return NotesViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(NotesViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = NotesViewController()
            controller.viewModel = container.resolve(NotesViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleChatSearchViewController(_ container: Container) {
        container.register(ChatSearchViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return ChatSearchViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(ChatSearchViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = ChatSearchViewController()
            controller.viewModel = container.resolve(ChatSearchViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    // check if the existing one can be used
    
//    private func assembleCallHistoryViewController(_ container: Container) {
//         container.register(CallHistoryViewModel.self) { (resolver, coordinator: AppCoordinator) in
//             let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
//             return CallHistoryViewModel(repository: repository, coordinator: coordinator)
//         }.inObjectScope(.transient)
//
//         container.register(CallHistoryViewController.self) { (resolver, coordinator: AppCoordinator) in
//             let controller = CallHistoryViewController()
//             controller.viewModel = container.resolve(CallHistoryViewModel.self, argument: coordinator)
//             return controller
//         }.inObjectScope(.transient)
//    }
}
