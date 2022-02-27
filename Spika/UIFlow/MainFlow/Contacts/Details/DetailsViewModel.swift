//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation

class DetailsViewModel: BaseViewModel {
    
    let id: Int
    
    init(repository: Repository, coordinator: Coordinator, id: Int) {
        self.id = id
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
    
    func presentCurrentChatScreen() {
        getAppCoordinator()?.popTopViewController(animated: false)
        getAppCoordinator()?.presentCurrentChatScreen(animated: false)
    }
}
