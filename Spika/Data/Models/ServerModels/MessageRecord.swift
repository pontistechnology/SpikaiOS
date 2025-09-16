//
//  MessageRecord.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.10.2022..
//

import Foundation

struct MessageRecord: Codable {
    let id: Int64
    let messageId: Int64
    let userId: Int64
    let createdAt: Int64
    let type: MessageRecordType?
    let reaction: String?
    let modifiedAt: Int64?
    let isDeleted: Bool
}

struct SomeMessageDetails: Codable {
    let id: Int64
    let totalUserCount: Int64
    let deliveredCount: Int64
    let seenCount: Int64
}

extension MessageRecord {
    init(messageRecordEntity: MessageRecordEntity) {
        self.init(id: messageRecordEntity.id,
                  messageId: messageRecordEntity.messageId,
                  userId: messageRecordEntity.userId,
                  createdAt: messageRecordEntity.createdAt,
                  type: MessageRecordType(rawValue: messageRecordEntity.type ?? ""),
                  reaction: messageRecordEntity.reaction,
                  modifiedAt: messageRecordEntity.modifiedAt, 
                  isDeleted: messageRecordEntity.isRemoved)
    }
}
