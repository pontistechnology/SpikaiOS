//
//  RoomUser.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.10.2022..
//

import Foundation

struct RoomUser: Codable {
    
    static var room: CodingUserInfoKey {
            return CodingUserInfoKey(rawValue: "room")!
    }
    
    
    let userId: Int64
    let isAdmin: Bool?
    let user: User

    // is not in api
    var roomId: Int64 = -1
}

extension RoomUser {
    
    
//    init(roomUserEntity: RoomUserEntity) {
//        self.init(userId: roomUserEntity.userId,
//                  isAdmin: roomUserEntity.isAdmin,
//                  user: User(entity: roomUserEntity.user!)) // TODO: check !
//    }
    
//    init(user:User) {
//        self.init(userId: 0, isAdmin: false, user: user)
//    }
}
