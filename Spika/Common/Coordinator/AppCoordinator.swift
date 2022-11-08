//
//  AppCoordinator.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Swinject
import Combine

class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let userDefaults = UserDefaults(suiteName: Constants.Strings.appGroupName)!
    let windowScene: UIWindowScene
    var subs = Set<AnyCancellable>()

    init(navigationController: UINavigationController, windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.navigationController = navigationController
        setupBindings()
    }
    
    //  This can be in scene delegate?
    func syncAndStartSSE() {
        guard let _ = userDefaults.string(forKey: Constants.UserDefaults.accessToken) else { return }
        let sse = Assembler.sharedAssembler.resolver.resolve(SSE.self, argument: self)
        sse?.syncAndStartSSE()
    }
    
    //  This can be in scene delegate?
    func stopSSE() {
        let sse = Assembler.sharedAssembler.resolver.resolve(SSE.self, argument: self)
        sse?.stopSSE()
    }
    
    func start() {
        if let _ = userDefaults.string(forKey: Constants.UserDefaults.accessToken),
           let userName = userDefaults.string(forKey: Constants.UserDefaults.displayName),
           !userName.isEmpty {
            presentHomeScreen(startSyncAndSSE: false)
        } else if let _ = userDefaults.string(forKey: Constants.UserDefaults.accessToken){
            presentEnterUsernameScreen()
        } else {
            presentEnterNumberScreen()
        }
    }
    
    // MARK: LOGIN FLOW
    func presentEnterNumberScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterNumberViewController.self, argument: self)!
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
    func presentEnterVerifyCodeScreen(number: String, deviceId: String) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterVerifyCodeViewController.self, arguments: self, number, deviceId)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCountryPicker(delegate: CountryPickerViewDelegate) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(CountryPickerViewController.self, arguments: self, delegate)!
        self.navigationController.present(viewController, animated: true)
    }
    
    func presentEnterUsernameScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(EnterUsernameViewController.self, argument: self)!
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
    // MARK: MAIN FLOW
    func presentHomeScreen(startSyncAndSSE: Bool,
                           startConfig: HomeViewController.HomeViewControllerStartConfig = HomeViewController.HomeViewControllerStartConfig.defaultConfig()) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(HomeViewController.self, arguments: self, startConfig)!
        if startSyncAndSSE {
            syncAndStartSSE()            
        }
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
    func getHomeTabBarItems(startingTab: Int) -> [TabBarItem] {
        let repository = Assembler.sharedAssembler.resolver.resolve(Repository.self, name: RepositoryType.production.name)!
        
        var tabs = [TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(AllChatsViewController.self, argument: self)!,
                           title: "Chats",
                           image: "chats",
                           position: 0,
                           isSelected: false,
                           indicationPublisher: repository.unreadRoomsPublisher.map { String($0) }.eraseToAnyPublisher()),
                TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(CallHistoryViewController.self, argument: self)!,
                           title: "Call History",
                           image: "callHistory",
                           position: 1,
                           isSelected: false,
                           indicationPublisher: nil),
                TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(ContactsViewController.self, argument: self)!,
                           title: "Contacts",
                           image: "contacts",
                           position: 2,
                           isSelected: false,
                           indicationPublisher: nil),
                TabBarItem(viewController: Assembler.sharedAssembler.resolver.resolve(SettingsViewController.self, argument: self)!,
                           title: "Settings",
                           image: "settings",
                           position: 3,
                           isSelected: false,
                           indicationPublisher: nil)]
        tabs[startingTab].isSelected = true
        return tabs
    }
    
    func presentDetailsScreen(user: User) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(DetailsViewController.self, arguments: self, user)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentSharedScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(SharedViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentFavoritesScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(FavoritesViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentNotesScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(NotesViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentChatSearchScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(ChatSearchViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCallHistoryScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(CallHistoryViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func popTopViewController(animated: Bool = true) {
        self.navigationController.popViewController(animated: animated)
    }
    
    func presentVideoCallScreen(url: URL) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(VideoCallViewController.self, arguments: self, url)!
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func presentSelectUserScreen() {
//        let viewController = Assembler.sharedAssembler.resolver.resolve(SelectUsersViewController.self, argument: self)!
//        let navC = UINavigationController(rootViewController: viewController)
//        navigationController.present(navC, animated: true, completion: nil)
    }
    
    func presentCurrentChatScreen(user: User) {
        let currentChatViewController = Assembler.sharedAssembler.resolver.resolve(CurrentChatViewController.self, arguments: self, user)!
        
        navigationController.pushViewController(currentChatViewController, animated: true)
    }
    
    func presentCurrentChatScreen(room: Room) {
        let currentChatViewController = Assembler.sharedAssembler.resolver.resolve(CurrentChatViewController.self, arguments: self, room)!
        
        navigationController.pushViewController(currentChatViewController, animated: true)
    }
    
    func presentNewGroupChatScreen(selectedMembers: [User]) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(NewGroupChatViewController.self, arguments: self, selectedMembers)!
        let selectUserVC = navigationController.presentedViewController as? UINavigationController
        selectUserVC?.pushViewController(viewController, animated: true)
    }
    
    func presentMessageDetails(users: [User], records: [MessageRecord]) {
        // TODO: assemble this vc
        let viewControllerToPresent = MessageDetailsViewController(users: users, records: records)
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // Fallback on earlier versions
            // TODO: fix for ios 14
        }
        navigationController.present(viewControllerToPresent, animated: true)
    }
    
    func dismissViewController() {
        let currentVC = navigationController.presentedViewController as? UINavigationController
        currentVC?.dismiss(animated: true)
    }
    
    func presentMoreActionsSheet() {
        let viewControllerToPresent = UIViewController()
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // Fallback on earlier versions
        }
        navigationController.present(viewControllerToPresent, animated: true)
    }
}

extension AppCoordinator {
    private func getWindowManager() -> WindowManager {
        Assembler.sharedAssembler.resolver.resolve(WindowManager.self, argument: windowScene)!
    }
    
    private func setupBindings() {
        getWindowManager()
            .notificationTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.presentCurrentChatScreen(room: info.room)
            }.store(in: &subs)
    }
    
    func showNotification(info: MessageNotificationInfo) {
        DispatchQueue.main.async { [weak self] in
            if let lastVC = self?.navigationController.viewControllers.last,
               !lastVC.isKind(of: CurrentChatViewController.self) {
                self?.getWindowManager().showNotificationWindow(info: info)
            }
        }
    }
    
    func changeIndicatorColor(to color: UIColor) {
        getWindowManager().changeIndicatorColor(to: color)
    }
    
    func showError(message: String) {
        getWindowManager().showPopUp(for: .errorMessage(message))
    }
    
    func showAlertView(title: String, message: String, buttons: [AlertViewButton]) -> PassthroughSubject<PopUpPublisherType, Never> {
        getWindowManager().showPopUp(for: .alertView(title: title,
                                                     message: message,
                                                     buttons: buttons))
        return getWindowManager().popUpPublisher
    }
}
