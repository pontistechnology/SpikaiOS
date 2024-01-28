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
    @Published var room: Room?
    let detailsMode: ChatDetailsMode
    @Published var showAddMembersScreen = false
    
    var isMyUserAdmin: Bool {
        room?.users.first(where: { $0.userId == myUserId })?.isAdmin ?? false
    }
    
    init(repository: Repository, coordinator: Coordinator, 
         detailsMode: ChatDetailsMode, actionPublisher: ActionPublisher) {
        self.detailsMode = detailsMode
        self.room = detailsMode.room
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        setupBindings()
        checkLocalPrivateRoom()
    }
    
    func setupBindings() {
        actionPublisher?.sink { [weak self] appAction in
            switch appAction {
            case .addToExistingRoom(let userIds):
                self?.updateRoomUsers(action: .addGroupUsers(userIds: userIds))
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    func updateRoomUsers(action: UpdateRoomAction) {
        guard let roomId = room?.id else { return }
        repository.updateRoom(roomId: roomId, 
                              action: action)
        .sink { c in
            
        } receiveValue: { [weak self] response in
            guard let room = response.data?.room else { return }
            _ = self?.repository.updateRoomUsers(room: room)
            self?.room = room
            self?.actionPublisher?.send(.updateRoom(room: room))
        }.store(in: &subscriptions)
    }
    
    func removeUsersFromGroup(user: User) {
        showYesNo(title: "Remove from group",
                  message: "Are you sure you want to remove "
            .appending(user.getDisplayName())
            .appending(" from group?")) { [weak self] in
                guard let self else { return }
                updateRoomUsers(action: .removeGroupUsers(userIds: [user.id]))
            }
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

extension ChatDetails2ViewModel {
    func clickOnMemberRow(roomUser: RoomUser) {
        var actions = [AlertViewButton.regular(title: "Info")]
        
        if isMyUserAdmin {
            if roomUser.isAdmin ?? false {
                actions.append(.regular(title: "Dismiss as admin"))
            } else {
                actions.append(.regular(title: "Make group admin"))
            }
        }
        
        getAppCoordinator()?.showAlert(style: .actionSheet, actions: actions).sink(receiveValue: { [weak self] index in
            guard let self else { return }
            switch index {
            case 0:
                getAppCoordinator()?.presentChatDetailsScreen(detailsMode: .contact(roomUser.user))
            case 1:
                if isMyUserAdmin {
                    if roomUser.isAdmin ?? false {
                        showYesNo(title: "Dismiss as admin", 
                                  message: "Are you sure you want to dismiss "
                            .appending(roomUser.user.getDisplayName()
                            .appending(" as group admin?"))) { [weak self] in
                            guard let self else { return }
                            updateRoomUsers(action: .removeGroupAdmins(userIds: [roomUser.userId]))
                        }
                    } else {
                        showYesNo(title: "Make group admin", 
                                  message: "Are you sure you want to make "
                            .appending(roomUser.user.getDisplayName()
                            .appending(" as group admin?"))) { [weak self] in
                            guard let self else { return }
                            updateRoomUsers(action: .addGroupAdmins(userIds: [roomUser.userId]))
                        }
                    }
                }
            default:
                break
            }
        }).store(in: &subscriptions)
    }
    
    private func showYesNo(title: String, message: String, yes: @escaping ()->()) {
        getAppCoordinator()?.showAlert(title: title, message: message, style: .alert, actions: [.regular(title: .getStringFor(.yes)), .regular(title: .getStringFor(.no))], cancelText: nil).sink(receiveValue: { [weak self] index in
            guard let self else { return }
            switch index {
            case 0:
                yes()
            default:
                break
            }
        }).store(in: &subscriptions)
    }
}
