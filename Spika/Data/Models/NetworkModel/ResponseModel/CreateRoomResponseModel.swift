//
//  CreateRoomResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

struct CreateRoomResponseModel: Codable {
    let status: String?
    let data: RoomData?
    let error: String?
    let message: String?
}

struct RoomData: Codable {
    let room: Room
}

// TODO: move models
struct Room: Codable {
    let id: Int
    let type: String?
    let name: String?
    let avatarUrl: String?
    let createdAt: Int?
    let users: [RoomUser]?
}

extension Room {
    init(roomEntity: RoomEntity) {
        let roomUsers = roomEntity.users?.allObjects.compactMap{ RoomUser(roomUserEntity: $0 as? RoomUserEntity)}
        self.init(id: Int(roomEntity.id),
                  type: roomEntity.type,
                  name: roomEntity.name,
                  avatarUrl: roomEntity.avatarUrl,
                  createdAt: Int(roomEntity.createdAt),
                  users: roomUsers
                  )
    }
}

struct RoomUser: Codable {
    let userId: Int?
    let isAdmin: Bool?
    let user: User?
}

extension RoomUser {
    init?(roomUserEntity: RoomUserEntity?) {
        guard let roomUserEntity = roomUserEntity else {
            return nil
        }
        self.init(userId: Int(roomUserEntity.userId),
                  isAdmin: roomUserEntity.isAdmin,
                  user: User(entity: roomUserEntity.user)) // TODO: check !
    }
}
