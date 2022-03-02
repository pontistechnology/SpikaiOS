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
}

enum MessageType: String, Codable {
    case text
    case photo
    case video
    case voice
}
