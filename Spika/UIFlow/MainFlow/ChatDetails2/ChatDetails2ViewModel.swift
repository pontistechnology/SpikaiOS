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

enum ChatDetailsMode {
    case contact(User)
    case roomDetails(CurrentValueSubject<Room, Never>)
    
    var description: String {
        return switch self {
        case .contact:
            .getStringFor(.privateContact)
        case .roomDetails:
            .getStringFor(.group)
        }
    }
    
    var isPrivate: Bool {
        return switch self {
        case .contact: true
        case .roomDetails: false
        }
    }
    
    var isGroup: Bool { !isPrivate }
    
    var room: Room? { 
        return if case .roomDetails(let currentValueSubject) = self {
            currentValueSubject.value
        } else { 
            nil
        }
    }
}

class ChatDetails2ViewModel: BaseViewModel, ObservableObject {
    @Published var room: Room?
    let detailsMode: ChatDetailsMode
    let actionPublisher: ActionPublisher
    @Published var showAddMembersScreen = false
    
    var isMyUserAdmin: Bool {
        room?.users.first(where: { $0.userId == myUserId })?.isAdmin ?? false
    }
    
    init(repository: Repository, coordinator: Coordinator, 
         detailsMode: ChatDetailsMode, actionPublisher: ActionPublisher) {
        self.detailsMode = detailsMode
        self.room = detailsMode.room
        self.actionPublisher = actionPublisher
        super.init(repository: repository, coordinator: coordinator)
        setupBindings()
        checkLocalPrivateRoom()
    }
    
    func setupBindings() {
        actionPublisher.sink { [weak self] action in
            switch action {
            case .addToExistingRoom(let userIds):
                self?.addUsersToGroup(userIds: userIds)
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    func addUsersToGroup(userIds: [Int64]) {
        guard let roomId = room?.id else { return }
        repository.updateRoom(roomId: roomId, 
                              action: .addGroupUsers(userIds: userIds))
        .sink { c in
            
        } receiveValue: { [weak self] response in
            guard let room = response.data?.room else { return }
            _ = self?.repository.updateRoomUsers(room: room)
            self?.room = room
        }.store(in: &subscriptions)
    }
    
    func removeUsersFromGroup(userIds: [Int64]) {
        guard let roomId = room?.id else { return }
        repository.updateRoom(roomId: roomId,
                              action: .removeGroupUsers(userIds: userIds))
        .sink { c in
            
        } receiveValue: { [weak self] response in
            guard let room = response.data?.room else { return }
            _ = self?.repository.updateRoomUsers(room: room)
            self?.room = room
        }.store(in: &subscriptions)
    }
    
    func checkLocalPrivateRoom() {
        guard detailsMode.isPrivate,
              case .contact(let user) = detailsMode
        else { return }
        repository.checkLocalPrivateRoom(forUserId: user.id).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                break
            case .failure(_):
                print("no local room")
                checkOnlineRoom(userId: user.id)
            }
        } receiveValue: { [weak self] room in
            guard let self else { return }
            self.room = room
        }.store(in: &subscriptions)
    }
    
    func checkOnlineRoom(userId: Int64)  {
        repository.checkOnlineRoom(forUserId: userId).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        } receiveValue: { [weak self] response in
            guard let self else { return }
            if let room = response.data?.room {
                print("There is online room.")
                self.room = room
                _ = repository.saveLocalRooms(rooms: [room])
            } else {
                print("There is no online room, creating started...")
                createRoom(userId: userId)
            }
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int64) {
        repository.createOnlineRoom(userId: userId).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                showError(error.localizedDescription)
            }
        } receiveValue: { [weak self] response in
            guard let self else { return }
            guard let room = response.data?.room else { return }
            _ = repository.saveLocalRooms(rooms: [room])
            self.room = room
        }.store(in: &subscriptions)
    }
    
    var profilePictureUrl: URL? {
        return switch detailsMode {
        case .contact(let user):
            user.avatarFileId?.fullFilePathFromId()
        case .roomDetails(let currentValueSubject):
            currentValueSubject.value.avatarFileId?.fullFilePathFromId()
        }
    }
    
    var roomName: String {
        return switch detailsMode {
        case .contact(let user):
            user.getDisplayName()
        case .roomDetails(let currentValueSubject):
            currentValueSubject.value.name ?? "no name"
        }
    }
    
    var bellowNameText: String? {
        return switch detailsMode {
        case .contact(let user): user.telephoneNumber
        case .roomDetails: nil
        }
    }
    
    var isRoomPinned: Binding<Bool> {
        Binding(get: { [weak self] in self?.room?.pinned ?? false}) { [weak self] in
            self?.pinUnpin(pin: $0)
        }
    }
    
    var isRoomMuted: Binding<Bool> {
        Binding(get: { [weak self] in self?.room?.muted ?? false}) { [weak self] in
            self?.muteUnmute(mute: $0)
        }
    }
    
    private func pinUnpin(pin: Bool) {
        guard let roomId = room?.id else { return }
        repository
            .pinUnpinRoom(roomId: roomId, pin: pin)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                guard let self else { return }
                switch c {
                case .finished:
                    self.room?.pinned = pin
                    guard let room = self.room else { return }
                    _ = repository.saveLocalRooms(rooms: [room])
                case .failure(_):
                    showError(.getStringFor(.somethingWentWrongPiningRoom))
                }
            } receiveValue: { _ in
            }.store(in: &subscriptions)
    }
    
    private func muteUnmute(mute: Bool) {
        guard let roomId = room?.id else { return }
        repository
            .muteUnmuteRoom(roomId: roomId, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.room?.muted = mute
                    guard let room = self.room else { return }
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
    func showPhoneNumberOptions() {
        getAppCoordinator()?
        .showAlert(actions: [.regular(title: .getStringFor(.copy)),
                             .regular(title: .getStringFor(.addToContacts))
        ], cancelText: .getStringFor(.cancel))
        .sink(receiveValue: { [weak self] tappedIndex in
            switch tappedIndex {
            case 0:
                self?.copyPhoneNumber()
            case 1:
                self?.presentAddToContactsScreen()
            default:
                break
            }
        }).store(in: &subscriptions)
    }
    
    func copyPhoneNumber() {
        guard let room else { return }
        guard let friendUser = room.getFriendUserInPrivateRoom(myUserId: myUserId),
              let friendPhone = friendUser.telephoneNumber
        else { return }
        UIPasteboard.general.string = friendPhone
        showOneSecAlert(type: .copy)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        getAppCoordinator()?.popTopViewController()
    }
    
    func presentAddToContactsScreen() {
        guard let room else { return }
        guard let friendUser = room.getFriendUserInPrivateRoom(myUserId: myUserId),
              let friendPhone = friendUser.telephoneNumber
        else { return }
        
        let contact = CNMutableContact()
        contact.phoneNumbers = [CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue: friendPhone))]
        contact.givenName = friendUser.getDisplayName()
        getAppCoordinator()?.presentAddToContactsScreen(contact: contact).delegate = self
    }
    
    func showChatScreen() {
        guard let room else { return }
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
    
    func presentAddMembersScreen() {
        showAddMembersScreen = true
    }
}

// MARK: - Notes

extension ChatDetails2ViewModel {
    func presentAllNotesScreen() {
        guard let room else { return }
        getAppCoordinator()?.presentNotesScreen(roomId: room.id)
    }
}
