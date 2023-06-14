//
//  ServerSettingsModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 01.06.2023..
//

import Foundation

struct ServerSettingsResponseModel: Codable {
    let status: String?
    let data: ServerSettingsModel?
}

struct ServerSettingsModel: Codable {
    let teamMode: Bool
}
