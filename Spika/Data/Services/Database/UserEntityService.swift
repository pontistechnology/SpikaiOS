//
//  UserEntityService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import UIKit
import CoreData
import Combine

class UserEntityService {
    
    let coreDataStack: CoreDataStack!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getUsers() -> Future<[User], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                let fetchRequest = UserEntity.fetchRequest() // mislav NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
                do {
                    let userEntities = try context.fetch(fetchRequest)
                    let users = userEntities.map{ User(entity: $0) }
                    print("userentities count: ", userEntities.count, "users", users)
                    promise(.success(users.compactMap{ $0 }))
                } catch { //mislav let error as NSError
                    promise(.failure(error))
                }
            }
        }
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let _ = UserEntity(user: user, context: context)
                do {
                    try context.save()
                    promise(.success(user))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for user in users {
                    let _ = UserEntity(user: user, context: context)
                }
                do {
                    try context.save()
                    promise(.success(users))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    func getUser(withId id: Int) -> Future<User, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let fetchRequest = UserEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
                do {
                    let dbUsers = try context.fetch(fetchRequest)
                    if dbUsers.count == 0 {
                        promise(.failure(DatabseError.noSuchRecord))
                    } else if dbUsers.count > 1 {
                        promise(.failure(DatabseError.moreThanOne))
                    } else {
                        guard let user = User(entity: dbUsers.first) else {
                            print("GUARD getUser(UserEntityService) error: ")
                            promise(.failure(DatabseError.unknown))
                            return
                        }
                        promise(.success(user))
                    }
                } catch {
                    promise(.failure(error))
                }
                
            }
        }
    }
}

//    func getChatsForUser(user: User) -> Future<[LocalChat], Error> {
//        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
//        do {
//            let dbUser = try managedContext!.fetch(fetchRequest).first
//            if let dbUser = dbUser {
//                var chats: [LocalChat] = []
//                dbUser.chats?.forEach{ dbChat in
//                    chats.append(LocalChat(entity: dbChat))
//                }
//                return Future { promise in promise(.success(chats))}
//            } else {
//                return Future { promise in promise(.failure(NetworkError.requestFailed))}
//            }
//
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }

//    func addChatToUser(user: User, chat: LocalChat) -> Future<User, Error> {
//        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id)")
//        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
//        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
//        do {
//            let dbUser = try managedContext!.fetch(userRequest).first
//            let dbChat = try managedContext!.fetch(chatRequest).first
//            if let dbChat = dbChat {
//                dbUser?.addToChats(dbChat)
//                try managedContext!.save()
//            } else {
//                return Future { promise in promise(.failure(DatabseError.requestFailed))}
//            }
//            return Future { promise in promise(.success(user))}
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
//
//    func removeUsetFromChat(user: User, chat: LocalChat) -> Future<LocalChat, Error> {
//        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id)")
//        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
//        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
//        do {
//            let dbUser = try managedContext!.fetch(userRequest).first
//            let dbChat = try managedContext!.fetch(chatRequest).first
//            if let dbUser = dbUser {
//                dbChat?.removeFromUsers(dbUser)
//                try managedContext!.save()
//            } else {
//                return Future { promise in promise(.failure(DatabseError.requestFailed))}
//            }
//            return Future { promise in promise(.success(chat))}
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
//
//    func updateUser(_ user: User) -> Future<User, Error> {
//        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
//        do {
//            let dbUser = try managedContext!.fetch(fetchRequest).first
//            if let dbUser = dbUser {
//                dbUser.setValue(user.localName, forKey: "localName")
//                dbUser.setValue(user.loginName, forKey: "loginName")
//                dbUser.setValue(user.avatarUrl, forKey: "avatarUrl")
//                dbUser.setValue(user.blocked, forKey: "blocked")
//                dbUser.setValue(user.modifiedAt, forKey: "modifiedAt")
//                try managedContext!.save()
//                return Future { promise in promise(.success(user))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
//            }
//
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }

//    func deleteUser(_ user: User) -> Future<User, Error> {
//        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id)")
//        do {
//            let dbUser = try managedContext!.fetch(fetchRequest).first
//            if let dbUser = dbUser {
//                managedContext!.delete(dbUser)
//                try managedContext!.save()
//                return Future { promise in promise(.success(user))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
//            }
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }

//    func deleteAllUsers() -> Future<Bool, Error> {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Constants.Database.userEntity)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        deleteRequest.resultType = .resultTypeObjectIDs
//        do{
//            try managedContext!.execute(deleteRequest)
//            return Future { promise in promise(.success(true))}
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
