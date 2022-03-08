//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation
import Combine

class DetailsViewModel: BaseViewModel {
    
    let user: AppUser
    let userSubject: CurrentValueSubject<AppUser, Never>
    
    init(repository: Repository, coordinator: Coordinator, user: AppUser) {
        self.user = user
        self.userSubject = CurrentValueSubject<AppUser, Never>(user)
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
    
    func presentCurrentChatScreen(user: AppUser) {
//        getAppCoordinator()?.popTopViewController(animated: false)
        getAppCoordinator()?.presentCurrentChatScreen(user: user)
    }
}
