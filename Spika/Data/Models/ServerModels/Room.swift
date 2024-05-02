//
//  Room.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.10.2022..
//

import Foundation

struct Room: Codable {
    let id: Int64
    let type: RoomType
    let name: String?
    let avatarFileId: Int64?
    let createdAt: Int64
    let modifiedAt: Int64
    var muted: Bool
    let users: [RoomUser]
    let deleted: Bool
    let unreadCount: Int64
    var pinned: Bool
}

extension Room {
    init(roomEntity: RoomEntity, users: [RoomUser]) {
        self.init(id: roomEntity.id,
                  type: RoomType(rawValue: roomEntity.type ?? "private") ?? .privateRoom,
                  name: roomEntity.name,
                  avatarFileId: roomEntity.avatarFileId,
                  createdAt: roomEntity.createdAt,
                  modifiedAt: roomEntity.modifiedAt,
                  muted: roomEntity.muted,
                  users: users,
                  deleted: roomEntity.roomDeleted,
                  unreadCount: roomEntity.unreadCount,
                  pinned: roomEntity.pinned)
    }
    
    
    func compareWith(string: String) -> Bool {
        if let name,
           name.range(of: string, options: .caseInsensitive) != nil {
            return true
        }
        
        for user in self.users {
            if let userName = user.user.displayName,
               userName.range(of: string, options: .caseInsensitive) != nil {
                return true
            }
        }
        
        return false
    }

}

extension Room {
    func getFriendUserInPrivateRoom(myUserId: Int64) -> User? {
        return type == .privateRoom 
        ? users.first(where: { $0.user.id != myUserId })?.user
        : nil
    }
    
    func getDisplayNameFor(userId: Int64) -> String {
        return users.first(where: { $0.userId == userId})?.user.getDisplayName() ?? "no name"
    }
    
    func roomName(myUserId: Int64) -> String {
        return switch self.type {
        case .privateRoom:
            getFriendUserInPrivateRoom(myUserId: myUserId)?.getDisplayName() ?? "no name"
        case .groupRoom:
            name ?? "no name"
        }
    }
    
    func numberOfAdmins() -> Int {
        users.map({ $0.isAdmin }).count
    }
}

extension Room {
    func getAttributedStringForSystemMessage(message: Message) -> NSMutableAttributedString {
        let timeText = message.createdAt.convert(to: .HHmm).attributedString
        + " ".attributedString
        return timeText + makeAttributedString(message: message)
    }
    
    func getStringForSystemMessage(message: Message) -> String {
        makeAttributedString(message: message).string
    }
    
    private func makeAttributedString(message: Message) -> NSMutableAttributedString {
        guard let subjectId = message.body?.subjectId,
              let subject = message.body?.subject,
              let typeOfSystemMessage = message.body?.type,
              let objects = message.body?.objects,
              let firstObject = objects.first
        else {
            return (message.body?.text ?? "Missing system message").attributedString
        }
        
        
        
        // this is like this, because we dont know which object is which user, so only if we have them all, we can join them
        let subjectName: String
        let objectUsersNames: String
        
        if let roomUser = users.first(where: { $0.userId == subjectId }) {
            subjectName = roomUser.user.getDisplayName()
        } else {
            subjectName = subject
        }
        
        // use this variable only if context of objects is users (can be note)
        let objectIds = message.body?.objectIds
        let objectUsers = typeOfSystemMessage.isObjectContextUsers
        ? users
            .filter({ objectIds?.contains($0.id) ?? false})
            .map( { $0.user })
        : []
        if objects.count == objectUsers.count {
            objectUsersNames = objectUsers.map({ $0.getDisplayName() }).joined(separator: ", ")
        } else {
            objectUsersNames = objects.joined(separator: ", ")
        }
        
        let systemMessageText = switch typeOfSystemMessage {
            // we want to see what group was called, so we are using firstObject
        case .createdGroup:
            subjectName.bold()
            + " created group ".attributedString
            + firstObject.bold()
        case .updatedGroupName:
            subjectName.bold()
            + " changed the group name to ".attributedString
            + firstObject.bold()
            
            // subject action, we want subject name to be updated
        case .userLeftGroup:
            subjectName.bold()
            + " left the group".attributedString
        case .updatedGroupAvatar:
            subjectName.bold()
            + " updated the avatar of the group".attributedString
            
            // members stuff, names should be updated
        case .addedGroupMembers:
            subjectName.bold()
            + " added ".attributedString
            + objectUsersNames.bold()
            + " to the group".attributedString
        case .removedGroupMembers:
            subjectName.bold()
            + " removed ".attributedString
            + objectUsersNames.bold()
            + " from the group".attributedString
        case .addedGroupAdmins:
            subjectName.bold()
            + " added ".attributedString
            + objectUsersNames.bold()
            + " as group admin".attributedString
        case .removedGroupAdmins:
            subjectName.bold()
            + " dismissed ".attributedString
            + objectUsersNames.bold()
            + " as group admin".attributedString
            
            // note stuff, using firstObject, because always will be only one note, and we want its name at that moment
        case .createdNote:
            subjectName.bold()
            + " created note ".attributedString
            + firstObject.bold()
        case .updatedNote:
            subjectName.bold()
            + " updated note ".attributedString
            + firstObject.bold()
        case .deletedNote:
            subjectName.bold()
            + " deleted note ".attributedString
            + firstObject.bold()
        }
        
        return systemMessageText
    }
}
