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
    
    let coreDataStack: CoreDataStack!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getMessages(forRoomId id: Int) -> Future<[Message], Error>{
        Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                let fetchRequest = MessageEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.roomId), "\(id)")
                
                do {
                    let messagesEntities = try context.fetch(fetchRequest)
                    let messages = messagesEntities.map{ Message(messageEntity: $0)}
                    promise(.success(messages.compactMap{$0}))
                } catch {
                    promise(.failure(DatabseError.requestFailed))
                }
            }
        }
    }
    
    func saveMessage(message: Message) -> Future<(Message, NSManagedObjectID), Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let entity = MessageEntity(message: message, context: context)
                do {
                    try context.save()
                    if entity.objectID.isTemporaryID{
                        promise(.failure(DatabseError.savingError))
                    } else {
                        promise(.success((message, entity.objectID)))
                    }
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    func updateMessage(message: Message, objectId: NSManagedObjectID) -> Future<Message, Error> {
        Future { promise in
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                do {
                    try context.save()
                    promise(.success(message))
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    
    

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
