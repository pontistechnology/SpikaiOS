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
        assembleCurrentChatViewController(container)
        assembleNewGroup2ChatViewController(container)
        assembleSelectUsersOrGroupsView(container)
    }
    
    private func assembleCurrentChatViewController(_ container: Container) {        
        container.register(CurrentChatViewModel.self) { (resolver, coordinator: AppCoordinator, room: Room, messageId: Int64?) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CurrentChatViewModel(repository: repository, coordinator: coordinator, room: room, scrollToMessageId: messageId)
        }.inObjectScope(.transient)

        container.register(CurrentChatViewController.self) { (resolver, coordinator: AppCoordinator, room: Room, messageId: Int64?) in
            let controller = CurrentChatViewController()
            controller.viewModel = container.resolve(CurrentChatViewModel.self, arguments: coordinator, room, messageId)
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
    
    private func assembleNewGroup2ChatViewController(_ container: Container) {
        container.register(NewGroup2ChatViewModel.self) { (resolver, coordinator: AppCoordinator, p: ActionPublisher) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return NewGroup2ChatViewModel(repository: repository, coordinator: coordinator, actionPublisher: p)
        }.inObjectScope(.transient)

        container.register(NewGroup2ChatViewController.self) { (resolver, coordinator: AppCoordinator, p: ActionPublisher) in
            let viewModel = container.resolve(NewGroup2ChatViewModel.self, arguments: coordinator, p)!
            let controller = NewGroup2ChatViewController(rootView: NewGroup2ChatView(viewModel: viewModel))
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleSelectUsersOrGroupsView(_ container: Container) {
        container.register(SelectUsersOrGroupsViewModel.self) { (resolver, coordinator: AppCoordinator, p: ActionPublisher, purpose: SelectUsersOrGroupsPurpose) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return SelectUsersOrGroupsViewModel(repository: repository, coordinator: coordinator, actionPublisher: p, purpose: purpose)
        }.inObjectScope(.transient)

        container.register(SelectUsersOrGroupsView.self) { (resolver, coordinator: AppCoordinator, p: ActionPublisher, purpose: SelectUsersOrGroupsPurpose) in
            let viewModel = container.resolve(SelectUsersOrGroupsViewModel.self, arguments: coordinator, p, purpose)!
            return SelectUsersOrGroupsView(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
}
