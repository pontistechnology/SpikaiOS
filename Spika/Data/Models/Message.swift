//
//  Message.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation

public struct Message: Codable {
    var createdAt: String?
    var fileMimeType: String?
    var filePath: String?
    var fromDeviceType: String?
    var id: Int64
    var message: String?
    var messageType: String?
    var modifiedAt: String?
    var replyMessageId: Int64?
    var state: String?
    var toDeviceType: String?
    var chat: Chat?
    var reactions: [Reaction]?
    var user: User?
    
    init(chat: Chat, user: User, message: String, id: Int) {
        self.id = Int64(id)
        self.chat = chat
        self.user = user
        self.message = message
    }
    
    init(entity: MessageEntity) {
        self.id = Int64(entity.id)
        self.fileMimeType = entity.fileMimeType
        self.filePath = entity.filePath
        self.fromDeviceType = entity.fromDeviceType
        self.message = entity.message
        self.messageType = entity.messageType
        self.replyMessageId = entity.replyMessageId
        self.state = entity.state
        self.toDeviceType = entity.toDeviceType
        if let dbUser = entity.user {
            self.user = User(entity: dbUser)
        }
        if let dbChat = entity.chat {
            self.chat = Chat(entity: dbChat)
        }
        self.createdAt = entity.createdAt
        self.modifiedAt = entity.modifiedAt
    }
}
