//
//  ChatEntityService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import UIKit
import CoreData
import Combine

class ChatEntityService {
    var managedContext : NSManagedObjectContext? {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func getChats() -> Future<[LocalChat], Error> {
        let fetchRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        do {
            let objects = try managedContext?.fetch(fetchRequest)
            
            if let chatEntities = objects {
                let chats = chatEntities.map{ return LocalChat(entity: $0)}
                return Future { promise in promise(.success(chats))}
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func saveChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        _ = ChatEntity(insertInto: managedContext, chat: chat)
        do {
            try managedContext?.save()
            return Future { promise in promise(.success(chat))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func addUserToChat(chat: LocalChat, user: LocalUser) -> Future<LocalChat, Error> {
        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id)")
        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbUser = try managedContext?.fetch(userRequest).first
            let dbChat = try managedContext?.fetch(chatRequest).first
            if let dbUser = dbUser {
                dbChat?.addToUsers(dbUser)
                try managedContext?.save()
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            return Future { promise in promise(.success(chat))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func getUsersForChat(chat: LocalChat) -> Future<[LocalUser], Error> {
        let fetchRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbChat = try managedContext?.fetch(fetchRequest).first
            if let dbChat = dbChat {
                var users: [LocalUser] = []
                dbChat.users?.forEach{ dbUser in
                    users.append(LocalUser(entity: dbUser))
                }
                return Future { promise in promise(.success(users))}
            } else {
                return Future { promise in promise(.failure(NetworkError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func removeChatFromUser(user: LocalUser, chat: LocalChat) -> Future<LocalUser, Error> {
        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
        userRequest.predicate = NSPredicate(format: "id = %@", "\(user.id)")
        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        chatRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbUser = try managedContext?.fetch(userRequest).first
            let dbChat = try managedContext?.fetch(chatRequest).first
            if let dbChat = dbChat {
                dbUser?.removeFromChats(dbChat)
                try managedContext?.save()
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            return Future { promise in promise(.success(user))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func updateChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        let fetchRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbChat = try managedContext?.fetch(fetchRequest).first
            if let dbChat = dbChat {
                dbChat.setValue(chat.name, forKey: "name")
                dbChat.setValue(chat.type, forKey: "type")
                dbChat.setValue(chat.muted, forKey: "muted")
                dbChat.setValue(chat.pinned, forKey: "pinned")
                dbChat.setValue(chat.groupUrl, forKey: "groupUrl")
                dbChat.setValue(chat.typing, forKey: "typing")
                dbChat.setValue(chat.modifiedAt, forKey: "modifiedAt")
                try managedContext?.save()
                return Future { promise in promise(.success(chat))}
            } else {
                return Future { promise in promise(.failure(NetworkError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func deleteChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        let fetchRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(chat.id)")
        do {
            let dbChat = try managedContext?.fetch(fetchRequest).first
            if let dbChat = dbChat {
                managedContext?.delete(dbChat)
                try managedContext?.save()
                return Future { promise in promise(.success(chat))}
            } else {
                return Future { promise in promise(.failure(NetworkError.requestFailed))}
            }
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func deleteAllChats() -> Future<Bool, Error> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Constants.Database.chatEntity)
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
