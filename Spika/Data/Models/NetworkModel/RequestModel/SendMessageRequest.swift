//
//  SendMessageRequest.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct SendMessageRequest: Codable {
    let roomId: Int64
    let type: String
    let body: RequestMessageBody
    let localId: String
    let replyId: Int64?
}

struct RequestMessageBody: Codable {
    let text: String?
    let fileId: Int64?
    let thumbId: Int64?
}
