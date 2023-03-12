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
    var muted: Bool
    let users: [RoomUser]
    let deleted: Bool
    var pinned: Bool
}

extension Room {
    init(roomEntity: RoomEntity, users: [RoomUser]) {
        self.init(id: roomEntity.id,
                  type: RoomType(rawValue: roomEntity.type ?? "private") ?? .privateRoom,
                  name: roomEntity.name,
                  avatarFileId: roomEntity.avatarFileId,
                  createdAt: roomEntity.createdAt,
                  muted: roomEntity.muted,
                  users: users,
                  deleted: roomEntity.roomDeleted,
                  pinned: roomEntity.pinned)
    }
//    init(roomEntity: RoomEntity) {
////        print("INIT ROOM ENTITY: ", roomEntity.id, roomEntity.users?.count)
//        let roomUsers = roomEntity.users?.allObjects.compactMap{ RoomUser(roomUserEntity: $0 as! RoomUserEntity)} ?? []
//        
//        self.init(id: roomEntity.id,
//                  type: RoomType(rawValue: roomEntity.type ?? "private") ?? .privateRoom,
//                  name: roomEntity.name,
//                  avatarFileId: roomEntity.avatarFileId,
//                  createdAt: roomEntity.createdAt,
//                  muted: roomEntity.muted,
//                  users: roomUsers,
//                  deleted: roomEntity.roomDeleted,
//                  pinned: roomEntity.pinned
//                  )
//    }
}

extension Room {
    func getFriendUserInPrivateRoom(myUserId: Int64) -> User? {
        if type == .privateRoom {
            return users.first(where: { $0.user.id != myUserId })?.user
        } else {
            return nil
        }
    }
    
    func getDisplayNameFor(userId: Int64) -> String {
        return users.first(where: { $0.userId == userId})?.user.getDisplayName() ?? "no name"
    }
}
