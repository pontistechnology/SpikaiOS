//
//  RoomEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.04.2022..
//

import CoreData

class RoomEntityService {
    let managedContext = CoreDataManager.shared.managedContext
    static let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageEntity, in: CoreDataManager.shared.managedContext)!
    
    
}
