//
//  FileData.swift
//  Spika
//
//  Created by Nikola Barbarić on 30.03.2023..
//

import Foundation

struct FileData: Codable {
    let id: Int64?
    let fileName: String?
    let mimeType: String?
    let size: Int64?
    let metaData: MetaData?
}

extension FileData {
    init(entity: FileEntity) {
        self.init(id: entity.id,
                  fileName: entity.fileName,
                  mimeType: entity.mimeType,
                  size: entity.fileSize,
                  metaData: MetaData(width: entity.metaDataWidth,
                                     height: entity.metaDataHeight,
                                     duration: entity.metaDataDuration))
    }
}

struct MetaData: Codable {
    let width: Int64
    let height: Int64
    let duration: Int64
}
