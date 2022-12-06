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
    let body: MessageBody
    let localId: String
    let reply: Bool
}
