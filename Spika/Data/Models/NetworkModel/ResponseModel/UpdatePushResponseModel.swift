//
//  UpdatePushResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.04.2022..
//

import Foundation

struct UpdatePushResponseModel: Decodable {
    let status: String?
    let data: UpdatePushData?
    let message: String?
    let error: String?
}

struct UpdatePushData: Decodable {
    let device: Device?
}
