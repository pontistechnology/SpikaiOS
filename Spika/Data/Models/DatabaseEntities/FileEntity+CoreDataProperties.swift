//
//  FileEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.03.2023..
//
//

import Foundation
import CoreData


extension FileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileEntity> {
        return NSFetchRequest<FileEntity>(entityName: "FileEntity")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var fileSize: Int64
    @NSManaged public var id: Int64
    @NSManaged public var metaDataDuration: Int64
    @NSManaged public var metaDataHeight: Int64
    @NSManaged public var metaDataWidth: Int64
    @NSManaged public var mimeType: String?

}

extension FileEntity : Identifiable {

}
