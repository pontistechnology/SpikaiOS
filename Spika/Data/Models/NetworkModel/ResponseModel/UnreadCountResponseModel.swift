//
//  UnreadCountResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.03.2023..
//

import Foundation

struct UnreadCountResponseModel: Codable {
    let status: String?
    let data: UnreadCountData?
    let error: String?
    let message: String?
}

struct UnreadCountData: Codable {
    let unreadCounts: [UnreadCount]
}

struct UnreadCount: Codable {
    let roomId: Int64
    let unreadCount: Int64
}
