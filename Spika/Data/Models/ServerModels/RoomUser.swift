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

    // TODO: - dbr is not in api, ask stjepan
    let roomId: Int64
    
    init(roomUserEntity: RoomUserEntity, user: User, roomId: Int64) {
        self.init(userId: roomUserEntity.userId,
                  isAdmin: roomUserEntity.isAdmin,
                  user: user,
                  roomId: roomId)
    }
}
