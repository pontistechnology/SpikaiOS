//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int
    let fromDeviceId: Int
    let fromUserId: Int
    let id: Int
    let totalDeviceCount: Int
    let receivedCount: Int
    let seenCount: Int
    let roomId: Int
    let type: String
    let body: MessageBody
}

extension Message {
    init(text: String) {
        body = MessageBody(text: text)
        id = 999
        fromUserId = 999
        fromDeviceId = 999
        totalDeviceCount = 999
        receivedCount = 999
        seenCount = -1
        roomId = 999
        type = "text"
        createdAt = Int(Date().timeIntervalSince1970)
    }
}

struct MessageBody: Codable {
    let text: String
}

enum MessageType: String, Codable {
    case text
    case photo
    case video
    case voice
}

enum MessageState {
    case sent
    case delivered
    case seen
    case fail
    case waiting
}
