//
//  UploadFileRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.02.2022..
//

import Foundation

struct UploadChunkRequestModel: Codable {
    let chunk: String
    let offset: Int
    let clientId: String
}
