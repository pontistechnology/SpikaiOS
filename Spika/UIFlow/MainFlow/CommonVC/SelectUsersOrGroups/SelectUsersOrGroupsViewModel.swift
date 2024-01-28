//
//  SelectingUsersViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//

import Foundation
import SwiftUI

class SelectUsersOrGroupsViewModel: BaseViewModel, ObservableObject {
    var hideUserIds: [Int64]
    let purpose: SelectUsersOrGroupsPurpose
    @Published var searchTerm = ""
    @Published var selectedUsersAndGroups: [SelectedUserOrGroup] = []
    @Published var isUsersSelected = true
    
    let usersSortDescriptor = [
        NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
    
    let roomsSortDescriptor = [
        NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false)]
    
    var usersPredicate: NSPredicate? {
        searchTerm.isEmpty
        ? NSPredicate(format: "NOT (id IN %@)", hideUserIds)
        : NSPredicate(format: "(contactsName CONTAINS[c] '\(searchTerm)' OR telephoneNumber CONTAINS[c] '\(searchTerm)') AND NOT (id IN %@)", hideUserIds)
    }
    
    var roomsPredicate: NSPredicate? {
        searchTerm.isEmpty
        ? NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)'")
        : NSPredicate(format: "name CONTAINS[c] '\(searchTerm)'")
    }

    init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher, purpose: SelectUsersOrGroupsPurpose) {
        self.hideUserIds = purpose.hideUserIds
        self.purpose = purpose
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        hideUserIds.append(myUserId) // hiding my user
    }
    
    func doneButtonTap() {
        switch purpose {
        case .forwardMessages(let messageIds):
            actionPublisher?.send(.forwardMessages(messageIds: messageIds, userIds: selectedUsersAndGroups.onlyUserIds, roomIds: selectedUsersAndGroups.onlyRoomIds))
        case .addToExistingGroup:
            actionPublisher?.send(.addToExistingRoom(selectedUsersAndGroups.onlyUserIds))
        case .addToNewGroupCreationFlow:
            actionPublisher?.send(.newGroupFlowSelectUsers(selectedUsersAndGroups.onlyUsers))
        }
    }
}
