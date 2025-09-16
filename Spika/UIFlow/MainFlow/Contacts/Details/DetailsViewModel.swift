//
//  DetailsViewModel.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import Foundation
import Combine
import ContactsUI

//class DetailsViewModel: BaseViewModel {
//    
//    let user: User
//    var room: Room?
//    let userSubject: CurrentValueSubject<User, Never>
//    
//    init(repository: Repository, coordinator: Coordinator, user: User) {
//        self.user = user
//        self.userSubject = CurrentValueSubject<User, Never>(user)
//        super.init(repository: repository, coordinator: coordinator)
//        checkLocalPrivateRoom()
//    }
//}
//
//private extension DetailsViewModel {
//    
//    
//    
//    
//    func saveLocalRoom(room: Room) {
//       repository.saveLocalRooms(rooms: [room]).sink { [weak self] completion in
//           guard let _ = self else { return }
//           switch completion {
//
//           case .finished:
//               print("saved to local DB")
//           case .failure(_):
//               print("saving to local DB failed")
//           }
//       } receiveValue: { [weak self] rooms in
//           guard let self,
//                 let room = rooms.first
//           else { return }
//           self.room = room
//       }.store(in: &subscriptions)
//    }
//    
//    
//}
//
//// MARK: - navigation
//
//extension DetailsViewModel {
//    func presentVideoCallScreen(url: URL) {
//        getAppCoordinator()?.presentVideoCallScreen(url: url)
//    }
//    
//    func presentSharedScreen() {
//        getAppCoordinator()?.presentSharedScreen()
//    }
//    
//    func presentFavoritesScreen() {
//        getAppCoordinator()?.presentFavoritesScreen()
//    }
//    
//    func presentNotesScreen() {
//        guard let roomId = room?.id else { return }
//        getAppCoordinator()?.presentNotesScreen(roomId: roomId)
//    }
//    
//    func presentCallHistoryScreen() {
//        getAppCoordinator()?.presentCallHistoryScreen()
//    }
//    
//    func presentCurrentChatScreen() {
//        guard let room = room else { return }
//        getAppCoordinator()?.presentCurrentChatScreen(room: room)
//    }
//    
//    func presentAddToContactsScreen(name: String, number: String) {
//        let contact = CNMutableContact()
//        contact.phoneNumbers = [CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue: number))]
//        contact.givenName = name
//        getAppCoordinator()?.presentAddToContactsScreen(contact: contact).delegate = self
//    }
//}
//
//extension DetailsViewModel: CNContactViewControllerDelegate {
//    
//    func getPhoneNumberText() -> String {
//        if room?.type == .privateRoom {
//            return room?.getFriendUserInPrivateRoom(myUserId: myUserId)?.telephoneNumber ?? ""
//        } else {
//            return ""
//        }
//    }
//    
//    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
//        getAppCoordinator()?.popTopViewController()
//    }
//}
