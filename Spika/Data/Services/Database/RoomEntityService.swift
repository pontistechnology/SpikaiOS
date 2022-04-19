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
    
    func getPrivateRoom(forId id: Int) -> Future<NSManagedObjectID, Error> {
        // CDStack
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == 'private' AND ANY users.userId == %@", "\(id)") // TODO: chagne to user Id
        do {
            let rooms = try coreDataStack.mainMOC.fetch(fetchRequest)
            if rooms.count == 1 {
                return Future { promise in
                    promise(.success(rooms.first!.objectID))
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
    
    func saveRoom(_ room: Room) -> Future<NSManagedObjectID, Error> {
        
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let a = RoomEntity(room: room, context: context)
                do {
                    try context.save()
                    print("this room is saved: ", room)
                    let moID = a.objectID
                    guard !moID.isTemporaryID else { return }
                    promise(.success(moID))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
}

