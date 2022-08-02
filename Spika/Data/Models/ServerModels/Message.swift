//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int64?
    let fromUserId: Int64?
    let id: Int64?
    let localId: String?
    let totalUserCount: Int64?
    let deliveredCount: Int64?
    let seenCount: Int64?
    let roomId: Int64?
    let type: String?
    let body: MessageBody?
    let records: [MessageRecord]?
}

extension Message {
    init(createdAt: Int64, fromUserId: Int64, roomId: Int64, type: MessageType, body: MessageBody, localId: String) {
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
        self.init(createdAt: messageEntity.createdAt,
                  fromUserId: messageEntity.fromUserId,
                  id: Int64(messageEntity.id ?? "-1"),
                  localId: messageEntity.localId,
                  totalUserCount: messageEntity.totalUserCount,
                  deliveredCount: messageEntity.deliveredCount,
                  seenCount: messageEntity.seenCount,
                  roomId: messageEntity.roomId,
                  type: messageEntity.type, // check
                  body: MessageBody(text: messageEntity.bodyText ?? "", file: FileData(fileName: nil, mimeType: nil, path: messageEntity.imagePath, size: nil), fileId: nil, thumbId: nil),
                  records: messageRecords)
    }
    
    func getMessageState(myUserId: Int64) -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        guard let records = records,
              let totalUserCount = totalUserCount
        else {
            print("there is no records")
            return .fail
        }
        
        print("RECORDS: ", records)
        
        if records.filter { $0.type == "seen" && $0.userId != myUserId}.count == totalUserCount - 1 {
            return .seen
        }
        
        if records.filter { $0.type == "delivered" && $0.userId != myUserId}.count == totalUserCount - 1 {
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
    let file: FileData?
    let fileId: Int?
    let thumbId: Int?
}

struct FileData: Codable {
    let fileName: String?
    let mimeType: String?
    let path: String?
    let size: Int?
}

enum MessageType: String, Codable {
    case text
    case image
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
