//
//  AppAssembly.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Combine
import Swinject
import SwiftUI
import AVKit

final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleCoreDataStack(container)
        assemblePublishers(container)
        assembleMainRepository(container)
        assembleSSE(container)
        assembleWindowManager(container)
        assembleHomeViewController(container)
        assembleContactsViewController(container)
        assembleCallHistoryViewController(container)
        assembleAllChatsViewController(container)
        assembleChatDetailsViewController(container)
        assembleSettingsViewController(container)
        assemblePrivacySettingsViewController(container)
        assembleAppereanceSettingsViewController(container)
        assembleBlockedUsersSettingsViewController(container)
        assembleImageViewerViewController(container)
        assemblePdfViewerViewController(container)
        assembleUserSelectionViewController(container)
        assembleMessageActionsViewController(container)
        assembleMessageDetailsViewController(container)
        assembleCustomReactionsViewController(container)
        assembleVideoPlayerViewController(container)
    }
    
    private func assembleMainRepository(_ container: Container) {
        container.register(NetworkService.self) { r in
            return NetworkService()
        }.inObjectScope(.container)
        container.register(DispatchQueue.self) { r in
            return DispatchQueue(label: "com.spika.blockeduserservice", attributes: .concurrent)
        }.inObjectScope(.container)
        container.register(UserDefaults.self) { r in
            return UserDefaults(suiteName: Constants.Networking.appGroupName)!
        }.inObjectScope(.container)
        
        container.register(DatabaseService.self) { r in
            let coreDataStack = container.resolve(CoreDataStack.self)!
            return DatabaseService(coreDataStack: coreDataStack)
        }.inObjectScope(.container)

        container.register(Repository.self, name: RepositoryType.production.name) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return AppRepository(networkService: networkService,
                                 databaseService: databaseService,
                                 userDefaults: r.resolve(UserDefaults.self)!,
                                 phoneNumberParser: PhoneNumberParser())
        }.inObjectScope(.container)
    }
    
    private func assemblePublishers(_ container: Container) {
        container.register(CurrentValueSubject<Set<Int64>?,Never>.self) { resolver in
            let userDefaults = resolver.resolve(UserDefaults.self)
            let blockedArray = userDefaults?.value(forKey: "blocked_user_ids") as? [Int64]
            return CurrentValueSubject<Set<Int64>?,Never>(Set(blockedArray ?? []))
        }.inObjectScope(.container)
        container.register(CurrentValueSubject<Set<Int64>,Never>.self) { resolver in
            let userDefaults = resolver.resolve(UserDefaults.self)
            let confirmedArray = userDefaults?.value(forKey: "confirmed_user_ids") as? [Int64]
            return CurrentValueSubject<Set<Int64>,Never>(Set(confirmedArray ?? []))
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
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator, publisher: ActionPublisher) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return HomeViewModel(repository: repository, coordinator: coordinator, actionPublisher: publisher)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator, startTab: TabBarItem, publisher: ActionPublisher) in
            let controller = HomeViewController(viewModel: container.resolve(HomeViewModel.self, arguments: coordinator, publisher)!, startTab: startTab)
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
    
    private func assembleChatDetailsViewController(_ container: Container) {
        container.register(ChatDetails2ViewModel.self) { (resolver, coordinator: AppCoordinator, detailsMode: ChatDetailsMode, actionPublisher: ActionPublisher) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return ChatDetails2ViewModel(repository: repository, coordinator: coordinator, detailsMode: detailsMode, actionPublisher: actionPublisher)
        }.inObjectScope(.transient)
        
        container.register(ChatDetails2ViewController.self) { (resolver, coordinator: AppCoordinator, detailsMode: ChatDetailsMode, actionPublisher: ActionPublisher) in
            let controller = ChatDetails2ViewController(rootView: ChatDetails2View(viewModel: resolver.resolve(ChatDetails2ViewModel.self, arguments: coordinator, detailsMode, actionPublisher)!))
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleUserSelectionViewController(_ container: Container) {
        container.register(UserSelectionViewModel.self) { (resolver,
                                                           coordinator: AppCoordinator,
                                                           preselectedUsers: [User],
                                                           usersSelectedPublisher: PassthroughSubject<[User],Never>) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return UserSelectionViewModel(repository: repository,
                                          coordinator: coordinator,
                                          preselectedUsers: preselectedUsers,
                                          usersSelectedPublisher: usersSelectedPublisher)
        }.inObjectScope(.transient)
        
        container.register(UserSelectionViewController.self) { (resolver,
                                                                coordinator: AppCoordinator,
                                                                preselectedUsers: [User],
                                                                usersSelectedPublisher: PassthroughSubject<[User],Never>) in
            let controller = UserSelectionViewController(viewModel: resolver.resolve(UserSelectionViewModel.self, arguments: coordinator, preselectedUsers, usersSelectedPublisher)!)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleSettingsViewController(_ container: Container) {
        container.register(Settings2ViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return Settings2ViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(Settings2ViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = Settings2ViewController(rootView: Settings2View(viewModel: container.resolve(Settings2ViewModel.self, argument: coordinator)!))
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assemblePrivacySettingsViewController(_ container: Container){
        container.register(PrivacySettingsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return PrivacySettingsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(PrivacySettingsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = PrivacySettingsViewController()
            controller.viewModel = container.resolve(PrivacySettingsViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleAppereanceSettingsViewController(_ container: Container){
        container.register(AppereanceSettingsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return AppereanceSettingsViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(AppereanceSettingsViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = AppereanceSettingsViewController(rootView: AppereanceSettingsView(viewModel: container.resolve(AppereanceSettingsViewModel.self, argument: coordinator)!))
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleBlockedUsersSettingsViewController(_ container: Container){
        container.register(BlockedUsersViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return BlockedUsersViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(BlockedUsersViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = BlockedUsersViewController()
            controller.viewModel = container.resolve(BlockedUsersViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleImageViewerViewController(_ container: Container) {
        container.register(ImageViewerViewModel.self) { (resolver, coordinator: AppCoordinator, message: Message, senderName: String) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = ImageViewerViewModel(repository: repository, coordinator: coordinator)
            viewModel.message = message
            viewModel.senderName = senderName
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(ImageViewerViewController.self) { (resolver, coordinator: AppCoordinator, message: Message, senderName: String) in
            let controller = ImageViewerViewController()
            controller.viewModel = container.resolve(ImageViewerViewModel.self, arguments: coordinator, message, senderName)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleVideoPlayerViewController(_ container: Container) {
        container.register(VideoPlayerViewModel.self) { (resolver, coordinator: AppCoordinator, asset: AVAsset) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = VideoPlayerViewModel(repository: repository, coordinator: coordinator)
            viewModel.asset = asset
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(VideoPlayerViewController.self) { (resolver, coordinator: AppCoordinator, asset: AVAsset) in
            let controller = VideoPlayerViewController(viewModel: container.resolve(VideoPlayerViewModel.self, arguments: coordinator, asset)!)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assemblePdfViewerViewController(_ container: Container) {
        container.register(PdfViewerViewController.self) { (resolver, coordinator: AppCoordinator, shareType: ShareActivityType) in
            let controller = PdfViewerViewController(shareType: shareType)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleMessageActionsViewController(_ container: Container) {
        container.register(MessageActionsViewModel.self) { (resolver, coordinator: AppCoordinator, actions: [MessageAction]) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = MessageActionsViewModel(repository: repository, coordinator: coordinator, actions: actions)
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(MessageActionsViewController.self) { (resolver, coordinator: AppCoordinator, actions: [MessageAction]) in
            let viewModel = container.resolve(MessageActionsViewModel.self, arguments: coordinator, actions)!
            let controller = MessageActionsViewController(viewModel: viewModel)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleMessageDetailsViewController(_ container: Container) {
        container.register(MessageDetailsViewModel.self) { (resolver, coordinator: AppCoordinator, users: [User], message: Message) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = MessageDetailsViewModel(repository: repository, coordinator: coordinator, users: users, message: message)
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(MessageDetailsViewController.self) { (resolver, coordinator: AppCoordinator, users: [User], message: Message) in
            let viewModel = container.resolve(MessageDetailsViewModel.self, arguments: coordinator, users, message)!
            let controller = MessageDetailsViewController()
            controller.viewModel = viewModel
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleCustomReactionsViewController(_ container: Container) {
        container.register(CustomReactionsViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = CustomReactionsViewModel(repository: repository, coordinator: coordinator)
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(CustomReactionsViewController.self) { (resolver, coordinator: AppCoordinator) in
            return CustomReactionsViewController(viewModel: container.resolve(CustomReactionsViewModel.self, argument: coordinator)!)
        }.inObjectScope(.transient)
    }
}
