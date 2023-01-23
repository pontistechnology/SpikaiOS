//
//  BaseSettingsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation
import Combine

class BaseSettingsViewModel: BaseViewModel {
    
    let user = CurrentValueSubject<User?,Error>(nil)
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.fetchUserDetails()
    }
    
    func fetchUserDetails() {
        self.repository.fetchMyUserDetails()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { c in
            }, receiveValue: { [weak self] responseModel in
                self?.user.send(responseModel.data?.user)
            }).store(in: &self.subscriptions)
    }
    
}
