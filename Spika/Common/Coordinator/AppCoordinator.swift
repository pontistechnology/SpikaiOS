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
import Contacts
import ContactsUI
import SwiftUI
import CoreData


class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
    let windowScene: UIWindowScene
    var subs = Set<AnyCancellable>()
    var inAppNotificationCancellable: AnyCancellable?
    let actionsPublisher = ActionPublisher()

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
        let repository = Assembler.sharedAssembler.resolver.resolve(Repository.self, name: RepositoryType.production.name)!
        repository.getAppModeIsTeamChat()
            .sink { _ in
                
            } receiveValue: { [weak self] isTeamChat in
                self?.continueAfterServerSettings()
            }.store(in: &subs)
    }
    
    func continueAfterServerSettings() {
        if let _ = userDefaults.string(forKey: Constants.Database.accessToken),
           let userName = userDefaults.string(forKey: Constants.Database.displayName),
           !userName.isEmpty {
            presentHomeScreen(startSyncAndSSE: false)
        } else if let _ = userDefaults.string(forKey: Constants.Database.accessToken){
            presentEnterUsernameScreen()
        } else {
            presentTermsAndConditionsScreen()
        }
    }
    
    // MARK: LOGIN FLOW
    func presentTermsAndConditionsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(TermsAndConditionViewController.self, argument: self)!
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
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
        let viewController = Assembler.sharedAssembler.resolver.resolve(HomeViewController.self, arguments: self, startTab, actionsPublisher)!
        if startSyncAndSSE {
            syncAndStartSSE()            
        }
        self.navigationController.setViewControllers([viewController], animated: false)
    }
    
    func presentSharedScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(SharedViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentFavoritesScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(FavoritesViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentNotesScreen(roomId: Int64) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(AllNotesViewController.self, arguments: self, roomId)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentOneNoteScreen(noteState: NoteState) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(OneNoteViewController.self, arguments: self, noteState)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCallHistoryScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(CallHistoryViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func popTopViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
    
    func presentVideoCallScreen(url: URL) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(VideoCallViewController.self, arguments: self, url)!
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func presentStartNewPrivateChatScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(NewPrivateChatViewController2.self, arguments: self, actionsPublisher)!
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCreateNewGroup2ChatScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(NewGroup2ChatViewController.self, arguments: self, actionsPublisher)!
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func getSelectUsersOrGroupsView(purpose: SelectUsersOrGroupsPurpose) -> SelectUsersOrGroupsView {
        return Assembler.sharedAssembler.resolver.resolve(SelectUsersOrGroupsView.self, arguments: self, actionsPublisher, purpose)!
    }
    
    func presentUserSelection(preselectedUsers: [User], usersSelectedPublisher: PassthroughSubject<[User],Never>) {
        let viewController = Assembler.sharedAssembler.resolver.resolve(UserSelectionViewController.self, arguments: self, preselectedUsers,usersSelectedPublisher)!
        let navC = UINavigationController(rootViewController: viewController)
        navigationController.present(navC, animated: true, completion: nil)
    }
    
    func presentChatDetailsScreen(detailsMode: ChatDetailsMode) {
        let roomDetailsViewController = Assembler.sharedAssembler.resolver.resolve(ChatDetails2ViewController.self, arguments: self, detailsMode, actionsPublisher)!
        navigationController.pushViewController(roomDetailsViewController, animated: true)
    }
    
    func presentCurrentChatScreen(room: Room, scrollToMessageId: Int64? = nil) {
        let currentChatViewController = Assembler.sharedAssembler.resolver.resolve(CurrentChatViewController.self, arguments: self, room, scrollToMessageId, actionsPublisher)!
        
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
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(viewControllerToPresent, animated: true)
        return viewControllerToPresent.publisher
    }
    
    func presentReactionsSheet(users: [User], records: [MessageRecord], myId: Int64) {
        let viewControllerToPresent = ReactionsViewController(users: users, records: records, actionPublisher: actionsPublisher, myId: myId)
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(viewControllerToPresent, animated: true)
    }
    
    func presentMessageActionsSheet(actions: [MessageAction]) -> PassthroughSubject<MessageAction, Never> {
        let viewControllerToPresent = Assembler.sharedAssembler.resolver.resolve(MessageActionsViewController.self, arguments: self, actions)!
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()] // can be changed to custom height when iOS 16
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(viewControllerToPresent, animated: true)
        return viewControllerToPresent.tapPublisher
    }
    
    func presentAVVideoController(asset: AVAsset) {
        let avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = avPlayer
        try? AVAudioSession.sharedInstance()
            .setCategory(AVAudioSession.Category.playback,
                         mode: AVAudioSession.Mode.default,
                         options: [])
        navigationController.present(avPlayerVC, animated: true) {
            avPlayer.play()
        }
    }
    
    func presentImageViewer(message: Message) {
        let imageViewerViewController = Assembler.sharedAssembler.resolver
            .resolve(ImageViewerViewController.self, arguments: self, message)!
        navigationController.pushViewController(imageViewerViewController, animated: true)
    }
    
    func presentPdfViewer(url: URL) {
        let pdfViewerViewController = Assembler.sharedAssembler.resolver
            .resolve(PdfViewerViewController.self, arguments: self, url)!
        navigationController.pushViewController(pdfViewerViewController, animated: true)
    }
    
    func presentPrivacySettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(PrivacySettingsViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentAddToContactsScreen(contact: CNContact) -> CNContactViewController {
        let vc = CNContactViewController(forNewContact: contact)
        self.navigationController.pushViewController(vc, animated: true)
        return vc
    }
    
    func presentAppereanceSettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(AppereanceSettingsViewController.self, argument: self)!
        self.navigationController.setViewControllers([viewController], animated: true)
    }
    
    func presentBlockedUsersSettingsScreen() {
        let viewController = Assembler.sharedAssembler.resolver.resolve(BlockedUsersViewController.self, argument: self)!
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCustomReactionPicker() -> PassthroughSubject<String, Never> {
        let viewController = Assembler.sharedAssembler.resolver.resolve(CustomReactionsViewController.self, argument: self)!
        navigationController.present(viewController, animated: true)
        return viewController.selectedEmojiPublisher
    }
    
    func presentForwardScreen(ids: [Int64], context: NSManagedObjectContext) {
        let vc = UIHostingController(rootView: getSelectUsersOrGroupsView(purpose: .forwardMessages(ids))
            .environment(\.managedObjectContext, context))
        navigationController.present(vc, animated: true)
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
    
    // send cancel as nil if you want to hide cancel action
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   style: UIAlertController.Style = .actionSheet,
                   actions: [AlertViewButton],
                   cancelText: String? = .getStringFor(.cancel)) -> Future<Int, Never> {
        self.showAlert(title: title, message: message, style: style, actions: actions, cancelText: cancelText, viewController: self.navigationController)
    }
        
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   style: UIAlertController.Style = .actionSheet,
                   actions: [AlertViewButton],
                   cancelText: String? = .getStringFor(.cancel),
                   viewController: UIViewController) -> Future<Int, Never> {
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
            DispatchQueue.main.async { [weak self] in
                viewController.dismiss(animated: true)
                viewController.present(actionSheet, animated: true)
            }
            
            if actions.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    actionSheet.dismiss(animated: true)
                }
            }
        }
    }
    
    func removeAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
    }
}
