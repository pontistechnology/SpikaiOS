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
        assembleSelectUserViewController(container)
        assembleCurrentChatViewController(container)
        assembleNewGroupChatViewController(container)
    }
    
    
    private func assembleSelectUserViewController(_ container: Container) {
        container.register(SelectUsersViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return SelectUsersViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(SelectUsersViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = SelectUsersViewController()
            controller.viewModel = container.resolve(SelectUsersViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleCurrentChatViewController(_ container: Container) {
        container.register(CurrentChatViewModel.self) { (resolver, coordinator: AppCoordinator, user: LocalUser) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CurrentChatViewModel(repository: repository, coordinator: coordinator, friendUser: user)
        }.inObjectScope(.transient)

        container.register(CurrentChatViewController.self) { (resolver, coordinator: AppCoordinator, user: LocalUser) in
            let controller = CurrentChatViewController()
            controller.viewModel = container.resolve(CurrentChatViewModel.self, arguments: coordinator, user)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleNewGroupChatViewController(_ container: Container) {
        container.register(NewGroupChatViewModel.self) { (resolver, coordinator: AppCoordinator, selectedUser: [User]) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return NewGroupChatViewModel(repository: repository, coordinator: coordinator, selectedUsers: selectedUser)
        }.inObjectScope(.transient)

        container.register(NewGroupChatViewController.self) { (resolver, coordinator: AppCoordinator, selectedUsers: [User]) in
            let controller = NewGroupChatViewController()
            controller.viewModel = container.resolve(NewGroupChatViewModel.self, arguments: coordinator, selectedUsers)
            return controller
        }.inObjectScope(.transient)
    }
}
