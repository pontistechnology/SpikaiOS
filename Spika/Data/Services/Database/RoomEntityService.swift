//
//  RoomEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.04.2022..
//

import CoreData
import Combine

class RoomEntityService {
    let managedContext = CoreDataManager.shared.managedContext
    static let entity = NSEntityDescription.entity(forEntityName: Constants.Database.roomEntity, in: CoreDataManager.shared.managedContext)!
    
    func getPrivateRoom(forId id: Int) -> Future<Room, Error> {
        
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func saveRoom(_ room: Room) -> Future<RoomEntity, Error> {
        let newRoom = RoomEntity(room: room)
        do {
            try managedContext.save()
            return Future { promise in
                promise(.success(newRoom))
            }
        } catch {
            return Future { promise in
                promise(.failure(DatabseError.unknown))
            }
        }
    }
    
    
}
