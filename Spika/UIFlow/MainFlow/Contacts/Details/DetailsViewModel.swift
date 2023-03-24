//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation
import Combine

class DetailsViewModel: BaseViewModel {
    
    let user: User
    var room: Room?
    let userSubject: CurrentValueSubject<User, Never>
    
    init(repository: Repository, coordinator: Coordinator, user: User) {
        self.user = user
        self.userSubject = CurrentValueSubject<User, Never>(user)
        super.init(repository: repository, coordinator: coordinator)
        checkLocalPrivateRoom()
    }
}

private extension DetailsViewModel {
    func checkLocalPrivateRoom() {
        repository.checkLocalPrivateRoom(forUserId: user.id).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                break
            case .failure(_):
                print("no local room")
                self.checkOnlineRoom()
            }
        } receiveValue: { [weak self] room in
            guard let self else { return }
            self.room = room
        }.store(in: &subscriptions)
    }
    
    func checkOnlineRoom()  {
        networkRequestState.send(.started())
        
        repository.checkOnlineRoom(forUserId: user.id).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                self.showError(error.localizedDescription)
                self.networkRequestState.send(.finished)
                // TODO: publish error
            }
        } receiveValue: { [weak self] response in
            
            guard let self else { return }
            
            if let room = response.data?.room {
                print("There is online room.")
                self.saveLocalRoom(room: room)
                self.networkRequestState.send(.finished)
            } else {
                print("There is no online room, creating started...")
                self.createRoom(userId: self.user.id)
            }
        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
       repository.saveLocalRooms(rooms: [room]).sink { [weak self] completion in
           guard let _ = self else { return }
           switch completion {

           case .finished:
               print("saved to local DB")
           case .failure(_):
               print("saving to local DB failed")
           }
       } receiveValue: { [weak self] rooms in
           guard let self,
                 let room = rooms.first
           else { return }
           self.room = room
       }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int64) {
        networkRequestState.send(.started())
        repository.createOnlineRoom(userId: userId).sink { [weak self] completion in
            guard let self else { return }
            self.networkRequestState.send(.finished)

            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                self.showError(error.localizedDescription)
                // TODO: present dialog
            }
        } receiveValue: { [weak self] response in
            guard let self else { return }
            if let errorMessage = response.message {
                //                PopUpManager.shared.presentAlert(with: (title: "Error", message: errorMessage), orientation: .horizontal, closures: [("Ok", {
                //                    self.getAppCoordinator()?.popTopViewController()
                //                })]) // TODO: - check
            }
            guard let room = response.data?.room else { return }
            self.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
}

// MARK: - navigation

extension DetailsViewModel {
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
        guard let room = room else { return }
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
}
