//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//
import CoreData
import Combine

enum DatabseError: Error {
    case requestFailed, noSuchRecord, unknown, moreThanOne, savingError

    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        case .moreThanOne: return "More than one record."
        case .savingError: return "Saving error."
        }
  }
}

class DatabaseService {
    let userEntityService: UserEntityService
    let chatEntityService: ChatEntityService
    let messageEntityService: MessageEntityService
    let roomEntityService: RoomEntityService
    let coreDataStack: CoreDataStack
    
    init(userEntityService: UserEntityService, chatEntityService: ChatEntityService, messageEntityService: MessageEntityService, roomEntityService: RoomEntityService, coreDataStack: CoreDataStack) {
        self.userEntityService = userEntityService
        self.chatEntityService = chatEntityService
        self.messageEntityService = messageEntityService
        self.roomEntityService = roomEntityService
        self.coreDataStack = coreDataStack
    }
    

}

extension DatabaseService {
    // TODO: CDStack organize inside services
    
    // Room
    
    func getPrivateRoom(forId id: Int) -> Future<RoomEntity, Error> {
        // CDStack
        let fetchRequest = NSFetchRequest<RoomEntity>(entityName: Constants.Database.roomEntity)
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)") // TODO: chagne to user Id
        do {
            let rooms = try coreDataStack.mainMOC.fetch(fetchRequest)
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
        
        return Future { [weak self] promise in
            // TODO: change thread to ID
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let a = RoomEntity(room: room, context: context)
                do {
                    try context.save()
                    print("this room is saved: ", room)
                    promise(.success(a))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    // USER
    
    func getUsers() -> Future<[LocalUser], Error> {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        do {
            let userEntities = try coreDataStack.mainMOC.fetch(fetchRequest)
            
            let users = userEntities.map{LocalUser(entity: $0)}
            print("userentities count: ", userEntities.count, "users", users)
            return Future { promise in promise(.success(users))}
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error> {
//        _ = UserEntity(insertInto: coreDataStack.backgroundMOC, user: user)
//        coreDataStack.saveBackgroundMOC()
        
        return Future { promise in promise(.success(user))}
    }
    
    func saveUsers(_ users: [LocalUser]) -> Future<[LocalUser], Error> {
//        var isSavedSuccessfully = false
//        coreDataStack.backgroundMOC.performAndWait {
//            for user in users {
//                _ = UserEntity(insertInto: self.coreDataStack.backgroundMOC, user: user)                
//            }
//            self.coreDataStack.saveBackgroundMOC()
//        }
        return Future { promise in promise(.success(users))} // TODO: CDStack change
    }
}
