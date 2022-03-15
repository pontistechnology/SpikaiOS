//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation
import Combine

class DetailsViewModel: BaseViewModel {
    
    let user: LocalUser
    let userSubject: CurrentValueSubject<LocalUser, Never>
    
    init(repository: Repository, coordinator: Coordinator, user: LocalUser) {
        self.user = user
        self.userSubject = CurrentValueSubject<LocalUser, Never>(user)
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func presentVideoCallScreen(url: URL) {
        getAppCoordinator()?.presentVideoCallScreen(url: url)
    }
    
    func presentSharedScreen() {
        getAppCoordinator()?.presentSharedScreen()
    }
    
    func presentChatSearchScreen() {
        getAppCoordinator()?.presentChatSearchScreen()
    }
    
    func presentFavoritesScreen() {
        getAppCoordinator()?.presentFavoritesScreen()
    }
    
    func presentNotesScreen() {
        getAppCoordinator()?.presentNotesScreen()
    }
    
    func presentCallHistoryScreen() {
        getAppCoordinator()?.presentCallHistoryScreen()
    }
    
    func presentCurrentChatScreen(user: LocalUser) {
//        getAppCoordinator()?.popTopViewController(animated: false)
        getAppCoordinator()?.presentCurrentChatScreen(user: user)
    }
}
