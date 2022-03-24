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
    var user: LocalUser?
    
    init(user: LocalUser, message: String, id: Int) {
        self.id = Int64(id)
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
//        if let dbUser = entity.user {
//            self.user = LocalUser(entity: dbUser)
//        }
        self.createdAt = Int(entity.createdAt)
        self.modifiedAt = Int(entity.modifiedAt)
    }
}
