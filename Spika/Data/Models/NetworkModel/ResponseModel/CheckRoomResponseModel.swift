//
//  CheckRoomResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct CheckRoomResponseModel: Codable {
    let status: String?
    let data: RoomData?
    let error: String?
}
