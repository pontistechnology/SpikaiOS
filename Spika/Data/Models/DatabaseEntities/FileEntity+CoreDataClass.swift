//
//  FileEntity+CoreDataClass.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.03.2023..
//
//

import Foundation
import CoreData

@objc(FileEntity)
public class FileEntity: NSManagedObject {
    convenience init(file: FileData, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.fileEntity, in: context) else {
            fatalError("Error, init File entity")
        }
        self.init(entity: entity, insertInto: context)
        
        self.fileName = file.fileName
        self.fileSize = file.size ?? 0
        self.id = file.id ?? 0
        self.mimeType = file.mimeType
        self.metaDataDuration = file.metaData?.duration ?? 0
        self.metaDataHeight = file.metaData?.height ?? 0
        self.metaDataWidth = file.metaData?.width ?? 0
    }
}
