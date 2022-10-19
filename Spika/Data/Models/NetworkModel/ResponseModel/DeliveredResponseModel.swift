//
//  DeliveredResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.05.2022..
//

import Foundation

struct DeliveredResponseModel: Codable {
    let status: String?
    let data: DeliveredData?
    let error: String?
    let message: String?
}

struct DeliveredData: Codable {
    let messageRecords: [MessageRecord]?
}


