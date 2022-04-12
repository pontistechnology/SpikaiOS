//
//  RoomEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.04.2022..
//

import CoreData
import Combine

class RoomUserEntityService {
    let managedContext = CoreDataManager.shared.managedContext
    static let entity = NSEntityDescription.entity(forEntityName: Constants.Database.roomUserEntity, in: CoreDataManager.shared.managedContext)!
    
    func saveRoomUser(roomUser: RoomUser) {
        
        
    }
    
    
}
