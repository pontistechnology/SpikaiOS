//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation
import Combine

class DetailsViewModel: BaseViewModel {
    
    let user: User
    let userSubject: CurrentValueSubject<User, Never>
    
    init(repository: Repository, coordinator: Coordinator, user: User) {
        self.user = user
        self.userSubject = CurrentValueSubject<User, Never>(user)
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
    
    func presentCurrentChatScreen(user: User) {
        getAppCoordinator()?.presentCurrentChatScreen(user: user)
    }
}
