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
    
    func getPrivateRoom(forId id: Int) -> Future<RoomEntity, Error> {
        let fetchRequest = NSFetchRequest<RoomEntity>(entityName: Constants.Database.roomEntity)
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)") // TODO: chagne to user Id
        do {
            let rooms = try managedContext.fetch(fetchRequest)
            if rooms.count == 1 {
                return Future { promise in
                    promise(.success(rooms.first!))
                }
            } else {
                return Future { promise in
                    promise(.failure(DatabseError.moreThanOne))
                }
            }
        } catch {
            return Future { promise in
                promise(.failure(error))
            }
        }
    }
    
    
    
    func saveRoom(_ room: Room) -> Future<RoomEntity, Error> {
        print("save room: ", room)
        
        let newRoom = RoomEntity(room: room)
        do {
            try managedContext.save()
            return Future { promise in
                promise(.success(newRoom))
            }
        } catch {
            print("Shit: ", error)
            return Future { promise in
                promise(.failure(DatabseError.unknown))
            }
        }
    }
    
    
}

