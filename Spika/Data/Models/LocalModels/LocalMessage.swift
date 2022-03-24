//
//  Message.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation

public struct LocalMessage: Codable {
    
    init(user: LocalUser, message: String, id: Int) {
    }
    
//    init(entity: MessageEntity) {
//        self.id = Int64(entity.id)
//        self.fileMimeType = entity.fileMimeType
//        self.filePath = entity.filePath
//        self.fromDeviceType = entity.fromDeviceType
//        self.message = entity.message
//        self.messageType = entity.messageType
//        self.replyMessageId = entity.replyMessageId
//        self.state = entity.state
//        self.toDeviceType = entity.toDeviceType
//        if let dbUser = entity.user {
//            self.user = LocalUser(entity: dbUser)
//        }
//        self.createdAt = Int(entity.createdAt)
//        self.modifiedAt = Int(entity.modifiedAt)
//    }
}
