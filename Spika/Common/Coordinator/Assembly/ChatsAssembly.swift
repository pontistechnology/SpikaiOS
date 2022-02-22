//
//  ContactsAssembly.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Swinject

class ChatsAssembly: Assembly {
    func assemble(container: Container) {
        assembleNewChatViewController(container)
        assembleCurrentChatViewController(container)
    }
    
    
    private func assembleNewChatViewController(_ container: Container) {
        container.register(NewChatViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return NewChatViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(NewChatViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = NewChatViewController()
            controller.viewModel = container.resolve(NewChatViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleCurrentChatViewController(_ container: Container) {
        container.register(CurrentChatViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CurrentChatViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(CurrentChatViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = CurrentChatViewController()
            controller.viewModel = container.resolve(CurrentChatViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
}
