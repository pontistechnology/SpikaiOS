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
}
