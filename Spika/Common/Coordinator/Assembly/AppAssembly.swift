//
//  AppAssembly.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Combine
import Swinject

final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        self.assembleCoreDataStack(container)
        self.assemblePublishers(container)
        self.assembleMainRepository(container)
        self.assembleSSE(container)
        self.assembleWindowManager(container)
        self.assembleHomeViewController(container)
        self.assembleContactsViewController(container)
        self.assembleCallHistoryViewController(container)
        self.assembleAllChatsViewController(container)
        self.assembleChatDetailsViewController(container)
        self.assembleSettingsViewController(container)
        self.assemblePrivacySettingsViewController(container)
        self.assembleAppereanceSettingsViewController(container)
        self.assembleBlockedUsersSettingsViewController(container)
        self.assembleImageViewerViewController(container)
        self.assembleUserSelectionViewController(container)
        self.assembleMessageActionsViewController(container)
        self.assembleMessageDetailsViewController(container)
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
            return DatabaseService(coreDataStack: coreDataStack, phoneNumberParser: PhoneNumberParser())
        }.inObjectScope(.container)

        container.register(Repository.self, name: RepositoryType.production.name) { r in
            let networkService = container.resolve(NetworkService.self)!
            let databaseService = container.resolve(DatabaseService.self)!
            return AppRepository(networkService: networkService, databaseService: databaseService, userDefaults: r.resolve(UserDefaults.self)!)
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
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return HomeViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator, startTab: TabBarItem) in
            let controller = HomeViewController(viewModel: container.resolve(HomeViewModel.self, argument: coordinator)!,
                                                startTab: startTab)
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
        container.register(ChatDetailsViewModel.self) { (resolver, coordinator: AppCoordinator, room: CurrentValueSubject<Room,Never>) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return ChatDetailsViewModel(repository: repository, coordinator: coordinator, room: room)
        }.inObjectScope(.transient)
        
        container.register(ChatDetailsViewController.self) { (resolver, coordinator: AppCoordinator, room: CurrentValueSubject<Room,Never>) in
            let controller = ChatDetailsViewController(viewModel: resolver.resolve(ChatDetailsViewModel.self, arguments: coordinator, room)!)
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
            let controller = AppereanceSettingsViewController()
            controller.viewModel = container.resolve(AppereanceSettingsViewModel.self, argument: coordinator)
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
        container.register(ImageViewerViewModel.self) { (resolver, coordinator: AppCoordinator, message: Message) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = ImageViewerViewModel(repository: repository, coordinator: coordinator)
            viewModel.message = message
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(ImageViewerViewController.self) { (resolver, coordinator: AppCoordinator, message: Message) in
            let controller = ImageViewerViewController()
            controller.viewModel = container.resolve(ImageViewerViewModel.self, arguments: coordinator, message)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleMessageActionsViewController(_ container: Container) {
        container.register(MessageActionsViewModel.self) { (resolver, coordinator: AppCoordinator, isMyMessage: Bool) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            let viewModel = MessageActionsViewModel(repository: repository, coordinator: coordinator, isMyMessage: isMyMessage)
            return viewModel
        }.inObjectScope(.transient)
        
        container.register(MessageActionsViewController.self) { (resolver, coordinator: AppCoordinator, isMyMessage: Bool) in
            let viewModel = container.resolve(MessageActionsViewModel.self, arguments: coordinator, isMyMessage)!
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
}
