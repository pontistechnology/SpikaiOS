//
//  UploadFileRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.02.2022..
//

import Foundation

struct UploadFileRequestModel: Codable {
    let chunk: String
    let offset: Int
    let total: Int
    let size: Int
    let mimeType: String
    let fileName: String
    let clientId: String
    let type: String
    let fileHash: String
    let relationId: String?
    
}
