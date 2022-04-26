//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

class HomeViewModel: BaseViewModel {
    
    func getHomeTabBarItems() -> [TabBarItem] {
        return getAppCoordinator()!.getHomeTabBarItems()
    }
    
    func updatePush() {
        repository.updatePushToken().sink { completion in
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                print("Update Push token error:" , error)
            }
        } receiveValue: { response in
            guard let _ = response.data?.device else {
                print("GUARD UPDATE PUSH RESPONSE")
                return
            }
        }.store(in: &subscriptions)
    }
}
