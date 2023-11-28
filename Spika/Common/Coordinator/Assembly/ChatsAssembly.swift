//
//  ContactsAssembly.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Swinject
import SwiftUI

class ChatsAssembly: Assembly {
    func assemble(container: Container) {
        assembleCurrentChatViewController(container)
        assembleNewGroup2ChatViewController(container)
    }
    
    private func assembleCurrentChatViewController(_ container: Container) {        
        container.register(CurrentChatViewModel2.self) { (resolver, coordinator: AppCoordinator, room: Room, messageId: Int64?) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CurrentChatViewModel2(repository: repository, coordinator: coordinator, room: room, scrollToMessageId: messageId)
        }.inObjectScope(.transient)

        container.register(CurrentChatViewController2.self) { (resolver, coordinator: AppCoordinator, room: Room, messageId: Int64?) in
            let vM = container.resolve(CurrentChatViewModel2.self, arguments: coordinator, room, messageId)!
            let controller = CurrentChatViewController2(rootView: AnyView(CurrentChatView2(viewModel: vM)
                .environment(\.managedObjectContext, vM.repository.getMainContext())))
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
        container.register(NewGroup2ChatViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return NewGroup2ChatViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(NewGroup2ChatViewController.self) { (resolver, coordinator: AppCoordinator) in
            let viewModel = container.resolve(NewGroup2ChatViewModel.self, argument: coordinator)!
            let controller = NewGroup2ChatViewController(rootView: NewGroup2ChatView(viewModel: viewModel))
            return controller
        }.inObjectScope(.transient)
    }
    
//    private func assembleSelectUsersView(_ container: Container) {
//        container.register(SelectUsersViewModel.self) { (resolver, coordinator: AppCoordinator) in
//            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
//            return SelectUsersViewModel(repository: repository, coordinator: coordinator)
//        }.inObjectScope(.transient)
//
//        container.register(SelectUsersView.self) { (resolver, coordinator: AppCoordinator) in
//            let viewModel = container.resolve(SelectUsersViewModel.self, argument: coordinator)!
//            return SelectUsersView(viewModel: viewModel)
//        }.inObjectScope(.transient)
//    }
}
