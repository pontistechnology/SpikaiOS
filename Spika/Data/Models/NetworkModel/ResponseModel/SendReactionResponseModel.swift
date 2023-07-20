//
//  SendReactionResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

struct SendReactionResponseModel: Codable {
    let status: String?
    let data: SendReactionData?
    let error: String?
    let message: String?
}

struct SendReactionData: Codable {
    let messageRecords: [MessageRecord]?
}
