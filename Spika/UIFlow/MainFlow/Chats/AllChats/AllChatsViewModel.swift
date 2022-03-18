//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class AllChatsViewModel: BaseViewModel {
    
    let roomsPublisher = CurrentValueSubject<[Room], Never>([])
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func  presentCurrentPrivateChatScreen() {
    }
    
    func getAllRooms() {
        repository.getAllRooms().sink { completion in
            print("get all rooms: ", completion)
        } receiveValue: { response in
            guard let rooms = response.data?.list else { return }
            self.roomsPublisher.send(rooms)
        }.store(in: &subscriptions)
    }
    
    func getMyUserId() -> Int {
        return repository.getMyUserId()
    }
}
