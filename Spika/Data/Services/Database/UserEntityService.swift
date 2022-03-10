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
    var managedContext : NSManagedObjectContext? {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func getUsers() -> Future<[User], Error> {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        do {
            let objects = try managedContext?.fetch(fetchRequest)
            
            if let userEntities = objects {
                let users = userEntities.map{ return User(entity: $0)}
                return Future { promise in promise(.success(users))}
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        _ = UserEntity(insertInto: managedContext, user: user)
        do {
            try managedContext?.save()
            return Future { promise in promise(.success(user))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        for user in users {
            _ = UserEntity(insertInto: managedContext, user: user)
        }
        do {
            try managedContext?.save()
            return Future { promise in promise(.success(users))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func getChatsForUser(user: User) -> Future<[Chat], Error> {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
        do {
            let dbUser = try managedContext?.fetch(fetchRequest).first
            if let dbUser = dbUser {
                var chats: [Chat] = []
                dbUser.chats?.forEach{ dbChat in
                    chats.append(Chat(entity: dbChat))
                }
                return Future { promise in promise(.success(chats))}
            } else {
                return Future { promise in promise(.failure(NetworkError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func addChatToUser(user: User, chat: Chat) -> Future<User, Error> {
        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbUser = try managedContext?.fetch(userRequest).first
            let dbChat = try managedContext?.fetch(chatRequest).first
            if let dbChat = dbChat {
                dbUser?.addToChats(dbChat)
                try managedContext?.save()
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            return Future { promise in promise(.success(user))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func removeUsetFromChat(user: User, chat: Chat) -> Future<Chat, Error> {
        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbUser = try managedContext?.fetch(userRequest).first
            let dbChat = try managedContext?.fetch(chatRequest).first
            if let dbUser = dbUser {
                dbChat?.removeFromUsers(dbUser)
                try managedContext?.save()
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            return Future { promise in promise(.success(chat))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func updateUser(_ user: User) -> Future<User, Error> {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
        do {
            let dbUser = try managedContext?.fetch(fetchRequest).first
            if let dbUser = dbUser {
                dbUser.setValue(user.localName, forKey: "localName")
                dbUser.setValue(user.loginName, forKey: "loginName")
                dbUser.setValue(user.avatarUrl, forKey: "avatarUrl")
                dbUser.setValue(user.blocked, forKey: "blocked")
                dbUser.setValue(user.modifiedAt, forKey: "modifiedAt")
                try managedContext?.save()
                return Future { promise in promise(.success(user))}
            } else {
                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func deleteUser(_ user: User) -> Future<User, Error> {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(user.id ?? -1)")
        do {
            let dbUser = try managedContext?.fetch(fetchRequest).first
            if let dbUser = dbUser {
                managedContext?.delete(dbUser)
                try managedContext?.save()
                return Future { promise in promise(.success(user))}
            } else {
                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
            }
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func deleteAllUsers() -> Future<Bool, Error> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Constants.Database.userEntity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        do{
            try managedContext?.execute(deleteRequest)
            return Future { promise in promise(.success(true))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
}
