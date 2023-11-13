//
//  ChatDetails2ViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import Foundation
import Combine
import ContactsUI
import SwiftUI

class ChatDetails2ViewModel: BaseViewModel, ObservableObject {
    @Published var room: Room
    private var publisher: CurrentValueSubject<Room, Never>
    
    
    init(repository: Repository, coordinator: Coordinator, roomPublisher: CurrentValueSubject<Room, Never>) {
        self.publisher = roomPublisher
        self.room = roomPublisher.value
        super.init(repository: repository, coordinator: coordinator)
    }
    
    var profilePictureUrl: URL? {
        return switch room.type {
        case .privateRoom:
            room.getFriendUserInPrivateRoom(myUserId: getMyUserId())?.avatarFileId?.fullFilePathFromId()
        case .groupRoom:
            room.avatarFileId?.fullFilePathFromId()
        }
    }
    
    var roomName: String { room.roomName(myUserId: getMyUserId())}
    
    var bellowNameText: String? {
        return room.type == .privateRoom
        ? room.getFriendUserInPrivateRoom(myUserId: getMyUserId())?.telephoneNumber
        : nil
    }
    
    var isRoomPinned: Binding<Bool> {
        Binding(get: { [weak self] in self?.room.pinned ?? false}) { [weak self] in
            self?.pinUnpin(pin: $0)
        }
    }
    
    var isRoomMuted: Binding<Bool> {
        Binding(get: { [weak self] in self?.room.muted ?? false}) { [weak self] in
            self?.muteUnmute(mute: $0)
        }
    }
    
    func pinUnpin(pin: Bool) {
        repository
            .pinUnpinRoom(roomId: room.id, pin: pin)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                guard let self else { return }
                switch c {
                case .finished:
                    room.pinned = pin
                    _ = repository.saveLocalRooms(rooms: [room])
                case .failure(_):
                    showError(.getStringFor(.somethingWentWrongPiningRoom))
                }
            } receiveValue: { _ in
            }.store(in: &subscriptions)
    }
    
    func muteUnmute(mute: Bool) {
        repository
            .muteUnmuteRoom(roomId: room.id, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    room.muted = mute
                    _ = repository.saveLocalRooms(rooms: [room])
                case .failure(_):
                    let message: String = mute ? .getStringFor(.somethingWentWrongMutingRoom) : .getStringFor(.somethingWentWrongUnmutingRoom)
                    showError(message)
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
}

// contact
extension ChatDetails2ViewModel: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        getAppCoordinator()?.popTopViewController()
    }
    
    func presentAddToContactsScreen() {
        guard let friendUser = room.getFriendUserInPrivateRoom(myUserId: getMyUserId()),
              let friendPhone = friendUser.telephoneNumber
        else { return }
        
        let contact = CNMutableContact()
        contact.phoneNumbers = [CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue: friendPhone))]
        contact.givenName = friendUser.getDisplayName()
        getAppCoordinator()?.presentAddToContactsScreen(contact: contact).delegate = self
    }
}

// MARK: - Notes

extension ChatDetails2ViewModel {
    func presentAllNotesScreen() {
        getAppCoordinator()?.presentNotesScreen(roomId: room.id)
    }
}
