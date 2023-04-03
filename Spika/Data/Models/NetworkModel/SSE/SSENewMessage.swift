//
//  SSENewMessage.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.04.2022..
//

import Foundation

struct SSENewMessage: Codable {
    let type: SSEEventType?
    let message: Message?
    let messageRecord: MessageRecord?
    let room: Room?
    let roomId: Int64?
}
