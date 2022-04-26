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
    let message: String?
}

struct SendMessageData: Codable {
    let message: Message
}
