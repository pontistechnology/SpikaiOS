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
}

extension RoomUser {
    init(roomUserEntity: RoomUserEntity) {
        self.init(userId: roomUserEntity.userId,
                  isAdmin: roomUserEntity.isAdmin,
                  user: User(entity: roomUserEntity.user!)) // TODO: check !
    }
    
    init(user:User) {
        self.init(userId: 0, isAdmin: false, user: user)
    }
}
