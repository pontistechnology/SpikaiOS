//
//  MessageEntityService.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import UIKit
import CoreData
import Combine

class MessageEntityService {
    
    let managedContext = CoreDataManager.shared.managedContext
    static let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageEntity,
                                                   in: CoreDataManager.shared.managedContext)!
    

//    func getMessages() -> Future<[LocalMessage], Error> {
//        let fetchRequest = NSFetchRequest<MessageEntity>(entityName: Constants.Database.messageEntity)
//        do {
//            let objects = try managedContext.fetch(fetchRequest)
//
//            if let messageEntities = objects {
//                let messages = messageEntities.map{ return LocalMessage(entity: $0)}
//                return Future { promise in promise(.success(messages))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.requestFailed))}
//            }
//
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
    
//    func getMessagesForChat(chat: LocalChat) -> Future<[LocalMessage], Error> {
//        let fetchRequest = NSFetchRequest<MessageEntity>(entityName: Constants.Database.messageEntity)
//        fetchRequest.predicate = NSPredicate(format: "chat.id = %@", "\(chat.id)")
//        do {
//            let objects = try managedContext.fetch(fetchRequest)
//            
//            if let messageEntities = objects {
//                let messages = messageEntities.map{ return LocalMessage(entity: $0)}
//                return Future { promise in promise(.success(messages))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.requestFailed))}
//            }
//            
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
    
//    func saveMessage(_ message: LocalMessage) -> Future<LocalMessage, Error> {
//        let dbMessage = MessageEntity(insertInto: managedContext, message: message)
//        let userRequest = NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
//        userRequest.predicate = NSPredicate(format: "id = %@", "\(message.user?.id ?? -1)")
//        let chatRequest = NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
//        chatRequest.predicate = NSPredicate(format: "id = %@", "\(message.chat?.id ?? -1)")
//        do {
//            if let dbUser = try managedContext.fetch(userRequest).first,
//               let dbChat = try managedContext.fetch(chatRequest).first {
//                dbMessage.chat = dbChat
//                dbMessage.user = dbUser
//                try managedContext.save()
//                return Future { promise in promise(.success(message))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.requestFailed))}
//            }
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
//
//    func updateMessage(_ message: LocalMessage) -> Future<LocalMessage, Error> {
//        let fetchRequest = NSFetchRequest<MessageEntity>(entityName: Constants.Database.messageEntity)
//        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(message.id)")
//        do {
//            let dbMessage = try managedContext.fetch(fetchRequest).first
//            if let dbMessage = dbMessage {
//                // TODO: dont use strings
//                dbMessage.setValue(message.user, forKey: "user")
//                dbMessage.setValue(message.toDeviceType, forKey: "toDeviceType")
//                dbMessage.setValue(message.replyMessageId, forKey: "replyMessageId")
//                dbMessage.setValue(message.messageType, forKey: "messageType")
//                dbMessage.setValue(message.fromDeviceType, forKey: "fromDeviceType")
//                dbMessage.setValue(message.filePath, forKey: "filePath")
//                dbMessage.setValue(message.fileMimeType, forKey: "fileMimeType")
//                dbMessage.setValue(message.message, forKey: "message")
//                dbMessage.setValue(message.state, forKey: "state")
//                dbMessage.setValue(message.modifiedAt, forKey: "modifiedAt")
//                try managedContext.save()
//                return Future { promise in promise(.success(message))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
//            }
//
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
//
//    func deleteMessage(_ message: LocalMessage) -> Future<LocalMessage, Error> {
//        let fetchRequest = NSFetchRequest<MessageEntity>(entityName: Constants.Database.messageEntity)
//        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(message.id)")
//        do {
//            let dbMessage = try managedContext.fetch(fetchRequest).first
//            if let dbMessage = dbMessage {
//                managedContext.delete(dbMessage)
//                try managedContext.save()
//                return Future { promise in promise(.success(message))}
//            } else {
//                return Future { promise in promise(.failure(DatabseError.noSuchRecord))}
//            }
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
//
//    func deleteAllUsers() -> Future<Bool, Error> {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Constants.Database.messageEntity)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        deleteRequest.resultType = .resultTypeObjectIDs
//        do{
//            try managedContext.execute(deleteRequest)
//            return Future { promise in promise(.success(true))}
//        } catch let error as NSError {
//            return Future { promise in promise(.failure(error))}
//        }
//    }
}
