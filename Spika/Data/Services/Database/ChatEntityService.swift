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
    
    func getChats() -> Future<[Chat], Error> {
        let fetchRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
        do {
            let objects = try managedContext?.fetch(fetchRequest)
            
            if let chatEntities = objects {
                let chats = chatEntities.map{ return Chat(entity: $0)}
                return Future { promise in promise(.success(chats))}
            } else {
                return Future { promise in promise(.failure(DatabseError.requestFailed))}
            }
            
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func saveChat(_ chat: Chat) -> Future<Chat, Error> {
        _ = ChatEntity(insertInto: managedContext, chat: chat)
        do {
            try managedContext?.save()
            return Future { promise in promise(.success(chat))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
    
    func updateChat(_ chat: Chat) -> Future<Chat, Error> {
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
    
    func deleteChat(_ chat: Chat) -> Future<Chat, Error> {
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
