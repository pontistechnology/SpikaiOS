//
//  BaseViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

class BaseViewModel {
    let coordinator: Coordinator
    let repository: Repository
    var subscriptions = Set<AnyCancellable>()
    let networkRequestState = CurrentValueSubject<RequestState, Never>(.finished)
    
    init(repository: Repository, coordinator: Coordinator) {
        self.repository = repository
        self.coordinator = coordinator
    }
    
    func getAppCoordinator() -> AppCoordinator? {
        return coordinator as? AppCoordinator
    }
    
    func getMyUserId() -> Int64 {
        return repository.getMyUserId()
    }
    
    func showError(_ message: String) {
        getAppCoordinator()?.showError(message: message)
    }
}
