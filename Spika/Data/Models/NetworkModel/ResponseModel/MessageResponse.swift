//
//  SendMessageResponse.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct MessageResponse: Codable {
    let status: String?
    let data: MessageData?
    let error: String?
    let message: String?
}

struct MessageData: Codable {
    let message: Message
}
