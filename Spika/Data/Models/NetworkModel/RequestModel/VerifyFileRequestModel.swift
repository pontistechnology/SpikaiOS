//
//  VerifyFileRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.04.2022..
//

import Foundation

struct VerifyFileRequestModel: Codable {
    let total: Int
    let size: Int
    let mimeType: String
    let fileName: String
    let type: String
    let fileHash: String?
    let relationId: Int
    let clientId: String
    let metaData: MetaData
}
