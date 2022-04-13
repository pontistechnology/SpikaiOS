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
    
    
//    func getChatsForUser(user: LocalUser) -> Future<[LocalChat], Error> {
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
    
//    func addChatToUser(user: LocalUser, chat: LocalChat) -> Future<LocalUser, Error> {
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
//    func removeUsetFromChat(user: LocalUser, chat: LocalChat) -> Future<LocalChat, Error> {
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
//    func updateUser(_ user: LocalUser) -> Future<LocalUser, Error> {
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
    
//    func deleteUser(_ user: LocalUser) -> Future<LocalUser, Error> {
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
    
}
