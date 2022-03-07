//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct MessageTest: Codable {
    let messageType: MessageType
    let textOfMessage: String?
    let replyMessageId: Int?
    let senderName: String
    let isMyMessage: Bool
}

enum MessageType: Codable {
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
