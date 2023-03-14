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
        Future { [weak self] promise in
            self?.coreDataStack.persistantContainer.performBackgroundTask { [weak self] context in
                guard let self = self else { return }
                // TODO: - dbr
                // find all roomUsers
                let roomUsersFR = RoomUserEntity.fetchRequest()
                roomUsersFR.predicate = NSPredicate(format: "userId == %d", id) // check
                guard let roomUsers = try? context.fetch(roomUsersFR)
                else {
                    promise(.failure(DatabseError.noSuchRecord)) // check
                }
                
                // find all private rooms with this users, should always be only one
                let possibleRoomsIds = roomUsers.map { $0.roomId }
                let roomFR = RoomEntity.fetchRequest()
                roomFR.predicate = NSPredicate(format: "type == 'private' AND roomId IN %@",
                                               "\(possibleRoomsIds)") // check string id int
                guard let rooms = try? context.fetch(roomFR),
                      rooms.count == 1,
                      let roomEntity = rooms.first,
                      let roomUserEntity = roomUsers.first(where: { $0.roomId == roomEntity.id })
                else {
                    promise(.failure(DatabseError.moreThanOne)) // check zero
                }
                
                // fetch user with user id
                guard let users = self.getUsers(id: [roomUserEntity.userId], context: context),
                      users.count == 1,
                      let user = users.first
                else {
                    promise(.failure(DatabseError.moreThanOne)) // check user
                }
                
                // convert from coredata entites to structs and return
                let roomUser = RoomUser(roomUserEntity: roomUserEntity,
                                        user: user)
                
                let room = Room(roomEntity: roomEntity, users: [roomUser]) // add me to list
                
                promise(.success(room))
            }
        }
    }
    
    func getRoom(forRoomId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistantContainer.performBackgroundTask { [weak self] context in
                guard let self = self else { return }
                let roomsFR = RoomEntity.fetchRequest()
                roomsFR.predicate = NSPredicate(format: "id == %d", id)
                guard let roomEntities = try? context.fetch(roomsFR),
                      roomEntities.count == 1,
                      let roomEntity = roomEntities.first,
                      let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: context)
                else {
                    promise(.failure(DatabseError.moreThanOne)) // check zero
                }
                let room = Room(roomEntity: roomEntity, users: roomUsers)
                promise(.success(room))
            }
        }
    }
    
    private func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]? {
        // fetch all [RoomUserEntity] from database
        let roomUsersFR = RoomUserEntity.fetchRequest()
        roomUsersFR.predicate = NSPredicate(format: "roomId == %d", roomId)
        
        guard let roomUserEntities = try? context.fetch(roomUsersFR)
        else {
            return nil
        }
        
        // fetch all [User] from database
        let users = getUsers(id: roomUserEntities.map({ $0.userId}), context: context)
        
        // return [RoomUser], should be same count as [RoomUserEntity]
        return roomUserEntities.map { roomUserEntity in
            guard let user = users?.first(where: { $0.id == roomUserEntity.userId })
            else {
                return
            }
            let roomUser = RoomUser(roomUserEntity: roomUserEntity, user: user, roomId: roomId)
        }
    }
    
    // copy exist
    private func getUsers(id: [Int64], context: NSManagedObjectContext) -> [User]? {
        let usersFR = UserEntity.fetchRequest()
        usersFR.predicate = NSPredicate(format: "id IN %@", id) // check
        guard let userEntities = try? context.fetch(usersFR)
        else {
            return nil
        }
        return userEntities.map { userEntity in
            User(entity: userEntity)
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
    
    func updateRoomUsers(_ room: Room) -> Future<Room, Error> {
        // TODO: - dbr
        // maybe delete all roomUsers with that room id, then save new ones
        Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let roomUserFR = RoomUserEntity.fetchRequest()
                roomUserFR.predicate = NSPredicate(format: "roomId == %d", room.id)

                do {
                    let roomUsers = try context.fetch(roomUserFR)
                    for roomUser in roomUsers {
                        context.delete(roomUser)
                    }
                    try context.save()
                    
                    room.users.forEach { rU in
                        _ = RoomUserEntity(roomUser: rU, insertInto: context)
                    }
                    try context.save()
                    promise(.success(room))
                } catch {
                    print("Error deleting RoomUsers: \(error)")
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
    
    func deleteRoom(roomId: Int64) -> Future<Bool, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let fr = RoomEntity.fetchRequest()
                fr.predicate = NSPredicate(format: "id == %d", roomId)
                guard let roomEntity = try? context.fetch(fr).first else { return }
                
                context.delete(roomEntity)
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure((DatabseError.savingError)))
                }
            }
        }
    }
}

