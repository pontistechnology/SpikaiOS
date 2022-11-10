//
//  RoomEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.04.2022..
//

import CoreData
import Combine
import Foundation

class RoomEntityService {
    
    let coreDataStack: CoreDataStack!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

// MARK: - Functions

extension RoomEntityService {
    
    func getRoom(forUserId id: Int64) -> Future<Room, Error> {
        Future { promise in
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
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
    
    func getRoom(forRoomId id: Int64) -> Future<Room, Error> {
        Future { promise in
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                let fetchRequest = RoomEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", id)
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
    
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error> {
        Future { promise in
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                let fetchRequest = RoomEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", roomId)
                do {
                    let rooms = try context.fetch(fetchRequest)
                    if rooms.count == 1 {
                        promise(.success(Room(roomEntity: rooms.first!)))
                    } else {
                        promise(.failure(DatabseError.moreThanOne))
                    }
                } catch {
                    promise(.failure(DatabseError.requestFailed))
                }
            }
        }
    }
        
    func saveRooms(_ rooms: [Room]) -> Future<[Room], Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for room in rooms {
                    let _ = RoomEntity(room: room, context: context)
                }
                do {
                    try context.save()
                    promise(.success(rooms))
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    func roomVisited(roomId: Int64) {
        coreDataStack.persistantContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            let fr = RoomEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %d", roomId)
            guard let rooms = try? context.fetch(fr) else { return }
            
            if rooms.count == 1 {
                rooms.first!.visitedRoom = Date().currentTimeMillis()
            } else {
                print("MORE THAN ONE ROOM.")
            }
            
            try? context.save()
        }
    }
}

