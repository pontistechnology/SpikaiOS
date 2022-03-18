//
//  GetAllRoomsRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 16.03.2022..
//

import Foundation

struct GetAllRoomsResponseModel: Codable {
    let status: String?
    let data: AllRoomsData?
    let error: String?
}

struct AllRoomsData: Codable {
    let limit: Int
    let count: Int
    let list: [Room]
}
