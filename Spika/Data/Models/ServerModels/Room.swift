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
    let avatarUrl: String?
    let createdAt: Int64
    let users: [RoomUser]
}

extension Room {
    init(roomEntity: RoomEntity) {
        print("INIT ROOM ENTITY: ", roomEntity.id, roomEntity.users?.count)
        let roomUsers = roomEntity.users?.allObjects.compactMap{ RoomUser(roomUserEntity: $0 as! RoomUserEntity)} ?? []
        
        self.init(id: roomEntity.id,
                  type: RoomType(rawValue: roomEntity.type ?? "private") ?? .privateRoom,
                  name: roomEntity.name,
                  avatarUrl: roomEntity.avatarUrl,
                  createdAt: roomEntity.createdAt,
                  users: roomUsers
                  )
    }
}

extension Room {
    // TODO: there is a same function in User model
    func getAvatarUrl() -> String? {
        if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
            if avatarUrl.starts(with: "http") {
                return avatarUrl
            } else if avatarUrl.starts(with: "/") {
                return Constants.Networking.baseUrl + avatarUrl.dropFirst()
            } else {
                return Constants.Networking.baseUrl + avatarUrl
            }
        } else {
            return nil
        }
    }
    
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
