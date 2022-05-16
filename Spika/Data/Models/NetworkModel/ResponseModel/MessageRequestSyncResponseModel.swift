//
//  MessageRequestSyncResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.05.2022..
//

import Foundation

struct MessageRecordSyncResponseModel: Codable {
    let status: String?
    let data: MessageRecordsSyncData?
    let error: String?
    let message: String?
}

struct MessageRecordsSyncData: Codable {
    let messageRecords: [MessageRecord]?
}
