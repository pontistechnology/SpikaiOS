//
//  SendMessageRequest.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct SendMessageRequest: Codable {
    let roomId: Int
    let type: String
    let body: MessageBody
}
