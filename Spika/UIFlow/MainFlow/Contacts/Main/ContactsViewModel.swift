//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class ContactsViewModel: BaseViewModel {
        
    var subs = Set<AnyCancellable>()
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func showDetailsScreen(user: User) {
        getAppCoordinator()?.presentDetailsScreen(user: user)
    }
    
    func refreshContacts() {
        repository.getAppModeIsTeamChat()
            .sink { _ in
                
            } receiveValue: { [weak self] isTeamMode in
                self?.repository.syncUsers()
                guard let isTeamMode, !isTeamMode else { return }
                self?.repository.syncContacts(force: true)
            }.store(in: &subs)
    }
    
}
