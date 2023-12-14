//
//  SendReactionResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

struct RecordResponseModel: Codable {
    let status: String?
    let data: RecordData?
    let error: String?
    let message: String?
}

struct RecordData: Codable {
    let messageRecords: [MessageRecord]?
}
