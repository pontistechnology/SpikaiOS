//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let id: Int
    let fromUserId: Int
    let fromDeviceId: Int
    let totalDeviceCount: Int
    let receivedCount: Int
    let seenCount: Int
    let roomId: Int
    let type: String
    let messageBody: MessageBody
    let createdAt: Int
}

extension Message {
    init(text: String) {
        messageBody = MessageBody(text: text)
        id = 999
        fromUserId = 999
        fromDeviceId = 999
        totalDeviceCount = 999
        receivedCount = 999
        seenCount = 999
        roomId = 999
        type = "text"
        createdAt = 999
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
