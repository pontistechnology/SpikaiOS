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
}

struct RoomData: Codable {
    let room: Room
}

struct Room: Codable {
    let id: Int
    let type: String
    let name: String
    let users: [RoomUser]
    let createdAt: Int
}

struct RoomUser: Codable {
    let userId: Int
    let isAdmin: Bool
    let user: User
}
