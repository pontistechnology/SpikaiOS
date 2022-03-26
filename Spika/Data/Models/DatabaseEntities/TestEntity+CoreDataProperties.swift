//
//  TestEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.03.2022..
//
//

import Foundation
import CoreData


extension TestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestEntity> {
        return NSFetchRequest<TestEntity>(entityName: "TestEntity")
    }

    @NSManaged public var testAttribute: String?
    @NSManaged public var drugi: Int16

}

extension TestEntity : Identifiable {

}
