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
    let messageRecords: [MessageRecord]
}

struct MessageRecord: Codable {
    let id: Int
    let messageId: Int
    let userId: Int
    let type: String
    let reaction: String
    let modifiedAt: Int
    let createdAt: Int
}
