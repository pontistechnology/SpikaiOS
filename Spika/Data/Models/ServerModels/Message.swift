//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int?
    let fromUserId: Int?
    let id: Int?
    let localId: String?
    let totalUserCount: Int?
    let deliveredCount: Int?
    let seenCount: Int?
    let roomId: Int?
    let type: String?
    let body: MessageBody?
    let records: [MessageRecord]?
}

extension Message {
    init(createdAt: Int, fromUserId: Int, roomId: Int, type: MessageType, body: MessageBody, localId: String) {
        self.body = body
        self.id = nil
        self.localId = localId
        self.fromUserId = fromUserId
        self.totalUserCount = nil
        self.deliveredCount = -1
        self.seenCount = -1
        self.roomId = roomId
        self.type = type.rawValue
        self.createdAt = createdAt
        self.records = nil
    }
    
    init(messageEntity: MessageEntity) {
        var messageRecords: [MessageRecord] = []
        
        if let records = messageEntity.records?.allObjects as? [MessageRecordEntity] {
            for messageRecordEntity in records {
                let record = MessageRecord(messageRecordEntity: messageRecordEntity)
                messageRecords.append(record)
            }
        }
        self.init(createdAt: Int(messageEntity.createdAt),
                  fromUserId: Int(messageEntity.fromUserId),
                  id: Int(messageEntity.id ?? "-1"),
                  localId: messageEntity.localId,
                  totalUserCount: Int(messageEntity.totalUserCount),
                  deliveredCount: Int(messageEntity.deliveredCount),
                  seenCount: Int(messageEntity.seenCount),
                  roomId: Int(messageEntity.roomId),
                  type: messageEntity.type ?? "todo check",
                  body: MessageBody(text: messageEntity.bodyText ?? ""),
                  records: messageRecords)
    }
    
    func getMessageState() -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        guard let records = records,
              let totalUserCount = totalUserCount
        else {
            print("there is no records")
            return .fail
        }
        
        print("RECORDS: ", records)
        
        if records.filter { $0.type == "seen" }.count == totalUserCount {
            return .seen
        }
        
        if records.filter { $0.type == "delivered" }.count == totalUserCount - 1 {
            return .delivered
        }
        
//        if(deliveredCount == totalUserCount) {
//            return .delivered
//        }
//
//        if(deliveredCount == 0) {
//            return .sent
//        }
//
//        if seenCount == nil || deliveredCount == nil {
//            return .fail
//        }
        
        return .waiting
    }
}

struct MessageBody: Codable {
    let text: String?
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
