//
//  SeenResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.10.2022..
//

import Foundation

struct SeenResponseModel: Codable {
    let status: String?
    let data: SeenData?
    let error: String?
    let message: String?
}

struct SeenData: Codable {
    let messageRecords: [MessageRecord]?
}
