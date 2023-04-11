//
//  AppCoordinator.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Swinject
import Combine
import AVKit
import AVFoundation

class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
    let windowScene: UIWindowScene
    var subs = Set<AnyCancellable>()
    var inAppNotificationCancellable: AnyCancellable?

    init(navigationController: UINavigationController, windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.navigationController = navigationController
        setupBindings()
    }
    
    //  This can be in scene delegate?
    func syncAndStartSSE() {
        guard let _ = userDefaults.string(forKey: Constants.Database.accessToken) else { return }
        let sse = Assembler.sharedAssembler.resolver.resolve(SSE.self, argument: self)
        sse?.startSSEAndSync()
    }
    
    //  This can be in scene delegate?
    func stopSSE() {
        let sse = Assembler.sharedAssembler.resolver.resolve(SSE.self, argument: self)
        sse?.stopSSE()
    }
    
    func start() {
        if let _ = userDefaults.string(forKey: Constants.Database.accessToken),
           let userName = userDefaults.string(forKey: Constants.Database.displayName),
           !userName.isEmpty {
            presentHomeScreen(startSyncAndSSE: false)
        } else if let _ = userDefaults.string(forKey: Constants.Database.accessToken){
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
    
    func presentEnterVerifyCodeScreen(number: TelephoneNumber, deviceId: String) {
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
                           startTab: TabBarItem = .chat(withChatId: nil)) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(HomeViewController.self, arguments: self, startTab)!
        if startSyncAndSSE {
            syncAndStartSSE()            
        }
        self.navigationController.setViewControllers([viewController], animated: false)
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
    
    func presentUserSelection(preselectedUsers: [User], usersSelectedPublisher: PassthroughSubject<[User],Never>) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(UserSelectionViewController.self, arguments: self, preselectedUsers,usersSelectedPublisher)!
        let navC = UINavigationController(rootViewController: viewController)
        navigationController.present(navC, animated: true, completion: nil)
    }
    
    func presentChatDetailsScreen(room: CurrentValueSubject<Room,Never>) {
        let roomDetailsViewController = Assembler.sharedAssembler.resolver.resolve(ChatDetailsViewController.self, arguments: self, room)!
        
        navigationController.pushViewController(roomDetailsViewController, animated: true)
    }
    
    func presentCurrentChatScreen(room: Room) {
        let currentChatViewController = Assembler.sharedAssembler.resolver.resolve(CurrentChatViewController.self, arguments: self, room)!
        
        navigationController.pushViewController(currentChatViewController, animated: true)
    }
    
    func presentNewGroupChatScreen(selectedMembers: [User]) {
        let usersSelectedPublisher = PassthroughSubject<[User],Never>()
        self.presentUserSelection(preselectedUsers: selectedMembers, usersSelectedPublisher: usersSelectedPublisher)
        
        usersSelectedPublisher
            .sink { [weak self] users in
                guard let self else { return }
                let viewController = Assembler.sharedAssembler.resolver.resolve(NewGroupChatViewController.self, arguments: self, users)!
                let navC = UINavigationController(rootViewController: viewController)
                self.navigationController.present(navC, animated: true, completion: nil)
            }.store(in: &self.subs)
    }
    
    func presentMessageDetails(users: [User], message: Message) {
        let viewControllerToPresent = Assembler.sharedAssembler.resolver.resolve(MessageDetailsViewController.self, arguments: self, users, message)!
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(viewControllerToPresent, animated: true)
    }
    
    func dismissViewController() {
        let currentVC = navigationController.presentedViewController
        currentVC?.dismiss(animated: true)
    }
    
    func presentMoreActionsSheet() -> PassthroughSubject<MoreActions, Never> {
        let viewControllerToPresent = MoreActionsViewController()
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // TODO: Fallback on earlier versions
        }
        navigationController.present(viewControllerToPresent, animated: true)
        return viewControllerToPresent.publisher
    }
    
    func presentReactionsSheet(users: [User], records: [MessageRecord]) {
        let viewControllerToPresent = ReactionsViewController(users: users, records: records)
        
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // Fallback on earlier versions
        }
        navigationController.present(viewControllerToPresent, animated: true)
    }
    
    func presentMessageActionsSheet() -> PassthroughSubject<MessageAction, Never> {
        let viewControllerToPresent = Assembler.sharedAssembler.resolver.resolve(MessageActionsViewController.self, argument: self)!
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium()] // can be changed to custom height when iOS 16
                sheet.prefersGrabberVisible = false
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            // TODO: Fallback on earlier versions
        }
        navigationController.present(viewControllerToPresent, animated: true)
        return viewControllerToPresent.tapPublisher
    }
    
    func presentAVVideoController(asset: AVAsset) {
        let avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = avPlayer
        navigationController.present(avPlayerVC, animated: true) {
            avPlayer.play()
        }
    }
    
    func presentImageViewer(message: Message) {
        let imageViewerViewController = Assembler.sharedAssembler.resolver
            .resolve(ImageViewerViewController.self, arguments: self, message)!
        navigationController.pushViewController(imageViewerViewController, animated: true)
    }
    
    func presentPrivacySettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(PrivacySettingsViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentAppereanceSettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(AppereanceSettingsViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentBlockedUsersSettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(BlockedUsersViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Window manager

extension AppCoordinator {
    private func getWindowManager() -> WindowManager {
        Assembler.sharedAssembler.resolver.resolve(WindowManager.self, argument: windowScene)!
    }
    
    private func setupBindings() {
        getWindowManager()
            .notificationTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
//                self?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: info.room.id))
                // TODO: - dbr add room to info
            }.store(in: &subs)
    }
    
    func showNotification(info: MessageNotificationInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let lastVC = self.navigationController.viewControllers.last,
               !lastVC.isKind(of: CurrentChatViewController.self) {
                self.inAppNotificationCancellable = self.getWindowManager().showNotificationWindow(info: info).sink(receiveValue: { [weak self] roomId in
                    self?.presentHomeScreen(startSyncAndSSE: false, startTab: .chat(withChatId: roomId))
                })
            }
        }
    }
    
    func changeIndicatorColor(to color: UIColor) {
        getWindowManager().changeIndicatorColor(to: color)
    }
    
    func showError(message: String) {
        getWindowManager().showPopUp(for: .errorMessage(message))
    }
    
    func showAlert(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .actionSheet,
                   actions: [AlertViewButton], cancelText: String? = .getStringFor(.cancel)) -> Future<Int, Never> {
        Future { [weak self] promise in
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: style)
            
            actions.enumerated().forEach { (index, action) in
                actionSheet.addAction(UIAlertAction(title:  action.title, style: action.style, handler: { _ in
                    promise(.success(index))
                }))
            }
            if let cancelText = cancelText {
                actionSheet.addAction(UIAlertAction(title:  cancelText, style: .cancel, handler: nil))
            }
            self?.navigationController.present(actionSheet, animated: true)
            
            if actions.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    actionSheet.dismiss(animated: true)
                }
            }
        }
    }
}

extension AppCoordinator {
    func changeAppereance(to mode: UIUserInterfaceStyle) {
        userDefaults.set(mode.rawValue, forKey: Constants.Database.selectedAppereanceMode)
        getWindowManager().changeAppereance(to: mode)
    }
}
