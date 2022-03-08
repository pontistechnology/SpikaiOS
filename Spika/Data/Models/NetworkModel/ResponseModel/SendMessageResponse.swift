//
//  SendMessageResponse.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct SendMessageResponse: Codable {
    let status: String?
    let data: SendMessageData?
    let error: String?
}

struct SendMessageData: Codable {
    let message: Message2
}

struct Message2: Codable {
    let id: Int
    let fromUserId: Int
    let fromDeviceId: Int
    let totalDeviceCount: Int
    let receivedCount: Int
    let seenCount: Int
    let roomId: Int
    let type: String
    let messageBody: MessageBody
    let createdAt: Int
}
