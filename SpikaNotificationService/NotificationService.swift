//
//  NotificationService.swift
//  SpikaNotificationService
//
//  Created by Nikola Barbarić on 27.04.2022..
//

import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {
    
    let coreDataStack = CoreDataStack()

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        print("best Attempt: ", bestAttemptContent)
        
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            guard let jsonData = (bestAttemptContent.userInfo["message"] as? String)?.data(using: .utf8) else { return }
            do {
                let message = try JSONDecoder().decode(Message.self, from: jsonData)
                bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
                self.coreDataStack.persistantContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    let _ = MessageEntity(message: message, context: context)
                    do {
                        try context.save()
                    } catch {
                        print("error notification saving")
                    }
                }
            } catch {
                print("Json Data error (Notificatoin Service)")
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
