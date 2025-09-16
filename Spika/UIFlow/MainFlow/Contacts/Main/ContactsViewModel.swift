//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class ContactsViewModel: BaseViewModel {
    func showDetailsScreen(user: User) {
        getAppCoordinator()?.presentChatDetailsScreen(detailsMode: .contact(user))
    }
    
    func refreshContacts() {
        repository.getAppModeIsTeamChat()
            .sink { _ in
                
            } receiveValue: { [weak self] isTeamMode in
                self?.repository.syncUsers(page: 1, startingTimestamp: Date().currentTimeMillis())
                guard let isTeamMode, !isTeamMode else { return }
                self?.repository.syncContacts(force: true)
            }.store(in: &subscriptions)
    }
}
