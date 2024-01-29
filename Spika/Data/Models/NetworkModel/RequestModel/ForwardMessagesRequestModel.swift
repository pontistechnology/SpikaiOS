//
//  ForwardMessagesRequest.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.12.2023..
//

import Foundation

struct ForwardMessagesRequestModel: Encodable {
    let messageIds: [Int64]
    let roomIds: [Int64]
    let userIds: [Int64]
}
