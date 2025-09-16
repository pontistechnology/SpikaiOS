//
//  ContactsAssembly.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Swinject
import Combine

class ContactsAssembly: Assembly {
    func assemble(container: Container) {
        assembleSharedViewController(container)
        assembleNotesViewController(container)
        assembleFavoritesViewController(container)
        assembleVideoCallViewController(container)
        assembleOneNoteViewController(container)
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
        container.register(AllNotesViewModel.self) { (resolver, coordinator: AppCoordinator, roomId: Int64) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = AllNotesViewModel(repository: repository, coordinator: coordinator)
            viewModel.roomId = roomId
            return viewModel
        }.inObjectScope(.transient)

        container.register(AllNotesViewController.self) { (resolver, coordinator: AppCoordinator, roomId: Int64) in
            let controller = AllNotesViewController()
            controller.viewModel = container.resolve(AllNotesViewModel.self, arguments: coordinator, roomId)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleOneNoteViewController(_ container: Container) {
        container.register(OneNoteViewModel.self) { (resolver, coordinator: AppCoordinator, noteState: NoteState) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = OneNoteViewModel(repository: repository, coordinator: coordinator)
            viewModel.noteStatePublisher = CurrentValueSubject<NoteState, Never>(noteState)
            return viewModel
        }.inObjectScope(.transient)

        container.register(OneNoteViewController.self) { (resolver, coordinator: AppCoordinator, noteState: NoteState) in
            let controller = OneNoteViewController()
            controller.viewModel = container.resolve(OneNoteViewModel.self, arguments: coordinator, noteState)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleVideoCallViewController(_ container: Container) {
        container.register(VideoCallViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return VideoCallViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)

        container.register(VideoCallViewController.self) { (resolver, coordinator: AppCoordinator, url: URL) in
            let controller = VideoCallViewController(url: url)
            controller.viewModel = container.resolve(VideoCallViewModel.self, argument: coordinator)
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
