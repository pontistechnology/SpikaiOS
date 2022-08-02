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
    let id: Int64
    let type: String?
    let name: String?
    let avatarUrl: String?
    let createdAt: Int64?
    let users: [RoomUser]?
}

enum RoomType: String {
    case privateRoom = "private"
    case groupRoom = "group"
}

extension Room {
    init(roomEntity: RoomEntity) {
        print("INIT ROOM ENTITY: ", roomEntity.id, roomEntity.users?.count)
        let roomUsers = roomEntity.users?.allObjects.compactMap{ RoomUser(roomUserEntity: $0 as? RoomUserEntity)}
        
        self.init(id: roomEntity.id,
                  type: roomEntity.type,
                  name: roomEntity.name,
                  avatarUrl: roomEntity.avatarUrl,
                  createdAt: roomEntity.createdAt,
                  users: roomUsers
                  )
    }
}

struct RoomUser: Codable {
    let userId: Int64
    let isAdmin: Bool?
    let roomId: Int64?
    let user: User?
}

extension RoomUser {
    init?(roomUserEntity: RoomUserEntity?) {
        guard let roomUserEntity = roomUserEntity else {
            return nil
        }
        self.init(userId: roomUserEntity.userId,
                  isAdmin: roomUserEntity.isAdmin,
                  roomId: roomUserEntity.roomId,
                  user: User(entity: roomUserEntity.user)) // TODO: check !
    }
}

// TODO: there is a same function in User model,
extension Room {
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
}

