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
