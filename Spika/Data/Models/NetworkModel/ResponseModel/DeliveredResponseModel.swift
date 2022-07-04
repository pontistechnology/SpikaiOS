//
//  DeliveredResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.05.2022..
//

import Foundation

struct DeliveredResponseModel: Codable {
    let status: String?
    let data: DeliveredData?
    let error: String?
    let message: String?
}

struct DeliveredData: Codable {
    let messageRecords: [MessageRecord]?
}

struct MessageRecord: Codable {
    let id: Int64?
    let messageId: Int64?
    let userId: Int64?
    let type: String?
    let reaction: String?
    let modifiedAt: Int64?
    let createdAt: Int64?
}

extension MessageRecord {
    init(messageRecordEntity: MessageRecordEntity) {
        self.init(id: messageRecordEntity.id,
                  messageId: messageRecordEntity.messageId,
                  userId: messageRecordEntity.userId,
                  type: messageRecordEntity.type,
                  reaction: messageRecordEntity.reaction,
                  modifiedAt: messageRecordEntity.modifiedAt,
                  createdAt: messageRecordEntity.createdAt)
    }
}
