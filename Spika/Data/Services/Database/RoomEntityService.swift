//
//  RoomEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.04.2022..
//

import CoreData
import Combine

class RoomEntityService {
    
    let coreDataStack: CoreDataStack!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

// MARK: - Functions

extension RoomEntityService {
    
    func getPrivateRoom(forId id: Int) -> Future<Room, Error> {
        Future { promise in
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                let fetchRequest = RoomEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "type == 'private' AND ANY users.userId == %@", "\(id)")
                // TODO: change predicate if
                do {
                    let rooms = try context.fetch(fetchRequest)
                    
                    if rooms.count == 1 {
                        let r = Room(roomEntity: rooms.first!)
                        promise(.success(r))
                    } else {
                        promise(.failure(DatabseError.moreThanOne))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func saveRoom(_ room: Room) -> Future<Room, Error> {
        
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let _ = RoomEntity(room: room, context: context)
                do {
                    try context.save()
                    print("this room is saved: ", room)
                    promise(.success(room))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
}

