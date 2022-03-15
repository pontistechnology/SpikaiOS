//
//  Message.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation

public struct LocalMessage: Codable {
    var createdAt: Int?
    var fileMimeType: String?
    var filePath: String?
    var fromDeviceType: String?
    var id: Int64
    var message: String?
    var messageType: String?
    var modifiedAt: Int?
    var replyMessageId: Int64?
    var state: String?
    var toDeviceType: String?
    var chat: LocalChat?
    var reactions: [LocalReaction]?
    var user: LocalUser?
    
    init(chat: LocalChat, user: LocalUser, message: String, id: Int) {
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
            self.user = LocalUser(entity: dbUser)
        }
        if let dbChat = entity.chat {
            self.chat = LocalChat(entity: dbChat)
        }
        self.createdAt = Int(entity.createdAt)
        self.modifiedAt = Int(entity.modifiedAt)
    }
}
