//
//  SendReactionRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

struct SendReactionRequestModel: Codable {
    let messageId: Int64
    let type: MessageRecordType
    let reaction: String
}
