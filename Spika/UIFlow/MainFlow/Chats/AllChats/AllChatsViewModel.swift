//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class AllChatsViewModel: BaseViewModel {
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentPrivateChatScreen(user: User) {
        getAppCoordinator()?.presentCurrentPrivateChatScreen(user: user)
    }
    
    func presentCurrentPrivateChatScreen(room: Room) {
        getAppCoordinator()?.presentCurrentPrivateChatScreen(room: room)
    }
    
    func getAllRooms() {
        repository.getAllRooms().sink { [weak self] completion in
            guard let _ = self else { return }
            print("get all rooms: ", completion)
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            guard let rooms = response.data?.list else { return }
            print("rooms server: ", rooms.count)
        }.store(in: &subscriptions)
    }
    
    func getMyUserId() -> Int {
        return repository.getMyUserId()
    }
}
