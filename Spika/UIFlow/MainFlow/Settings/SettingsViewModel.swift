//
//  SettingsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class SettingsViewModel: BaseViewModel {
    
    lazy var user: AnyPublisher<User?,Error> = {
        return self.repository.fetchMyUserDetails()
            .map { authModel in
                authModel.data?.user
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    } ()
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        
    }
    
}
