//
//  RoomUser.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.10.2022..
//

import Foundation

struct RoomUser: Codable {
    
    let userId: Int64
    let isAdmin: Bool?
    let user: User
    let roomId: Int64
}

extension RoomUser {
    init(roomUserEntity: RoomUserEntity, user: User) {
        self.init(userId: roomUserEntity.userId,
                  isAdmin: roomUserEntity.isAdmin,
                  user: user,
                  roomId: roomUserEntity.roomId)
    }
}
