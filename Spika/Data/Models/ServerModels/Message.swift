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
