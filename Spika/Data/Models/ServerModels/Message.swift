//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int64
    let modifiedAt: Int64
    let fromUserId: Int64
    let roomId: Int64
    let id: Int64?
    let localId: String?
    let totalUserCount: Int64?
    let deliveredCount: Int64?
    let seenCount: Int64?
    let replyId: Int64?
    let deleted: Bool
    let type: MessageType
    let body: MessageBody?
    let records: [MessageRecord]?
}

extension Message {
    init(createdAt: Int64, fromUserId: Int64, roomId: Int64, type: MessageType, body: MessageBody, replyId: Int64?, localId: String) {
        self.body = body
        self.id = nil
        self.localId = localId
        self.fromUserId = fromUserId
        self.totalUserCount = -1
        self.deliveredCount = -2 // needs to be different all 3 values, because state is calculated from this
        self.seenCount = -3
        self.replyId = replyId
        self.roomId = roomId
        self.type = type
        self.deleted = false
        self.createdAt = createdAt
        self.modifiedAt = createdAt
        self.records = nil
    }
    
    init(messageEntity: MessageEntity, fileData: FileData?, thumbData: FileData?, records: [MessageRecord]?) {
        self.init(createdAt: messageEntity.createdAt,
                  modifiedAt: messageEntity.modifiedAt,
                  fromUserId: messageEntity.fromUserId,
                  roomId: messageEntity.roomId,
                  id: Int64(messageEntity.id ?? "nil"),
                  localId: messageEntity.localId,
                  totalUserCount: messageEntity.totalUserCount,
                  deliveredCount: messageEntity.deliveredCount,
                  seenCount: messageEntity.seenCount,
                  replyId: Int64(messageEntity.replyId ?? "nil"),
                  deleted: messageEntity.isRemoved,
                  type: MessageType(rawValue: messageEntity.type ?? "") ?? .unknown, // check
                  body: MessageBody(text: messageEntity.bodyText ?? "",
                                    file: fileData, thumb: thumbData),
                  records: records)
    }
    
    func getMessageState(myUserId: Int64) -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        
        if seenCount == totalUserCount {
            return .seen
        }
        
        if deliveredCount == totalUserCount {
            return .delivered
        }
        
        if id != nil {
            return .sent
        }
        return .waiting
    }
    
    var pushNotificationText: String {
        switch type {
        case .text:
            return body?.text ?? " "
        case .image:
            return "[Photo message]"
        case .video:
            return "[Video message]"
        case .file:
            return "[File message]"
        case .audio:
            return "[Audio message]"
        case .unknown:
            return "[Unknown message]"
        }
    }
}

struct MessageBody: Codable {
    let text: String?
    let file: FileData?
    let thumb: FileData?
}

enum MessageType: String, Codable {
    // Type is used for MessageCells reuseIdentifier too
    case text
    case image
    case video
    case file
    case audio
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try MessageType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum MessageState {
    case sent
    case delivered
    case seen
    case fail
    case waiting
}
