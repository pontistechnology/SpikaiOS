//
//  NSManagedObjectContext+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.05.2023..
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func safeSave() throws {
        mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try save()
    }
}
