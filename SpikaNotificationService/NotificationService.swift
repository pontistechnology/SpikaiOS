//
//  NotificationService.swift
//  SpikaNotificationService
//
//  Created by Nikola Barbarić on 27.04.2022..
//

import UserNotifications
import CoreData
import Combine

class NotificationService: UNNotificationServiceExtension {
    
    var subs = Set<AnyCancellable>()
    let userDefaults = UserDefaults(suiteName: Constants.Strings.appGroupName)!
    let coreDataStack = CoreDataStack()
    lazy var repository = AppRepository(
        networkService: NetworkService(),
        databaseService: DatabaseService(userEntityService: UserEntityService(coreDataStack: coreDataStack),
                                         chatEntityService: ChatEntityService(coreDataStack: coreDataStack),
                                         messageEntityService: MessageEntityService(coreDataStack: coreDataStack),
                                         roomEntityService: RoomEntityService(coreDataStack: coreDataStack),
                                         coreDataStack: coreDataStack))

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let jsonData = (bestAttemptContent.userInfo["message"] as? String)?.data(using: .utf8),
                  let message = try? JSONDecoder().decode(Message.self, from: jsonData)
            else { return }
            
            repository.saveMessage(message: message).sink { c in
                print(c)
                switch c {
                case .finished:
                    break
                case let .failure(error):
                    bestAttemptContent.title = "SE: \(error)"
                    contentHandler(bestAttemptContent)
                }
            } receiveValue: { message in
                guard let id = message.id else {
                    bestAttemptContent.title = "guard error"
                    contentHandler(bestAttemptContent)
                    return }
                self.repository.sendDeliveredStatus(messageIds: [id]).sink { c in
                    switch(c) {
                    case .finished:
                        break
                    case let .failure(error):
                        bestAttemptContent.title = "Api: \(error)"
                        contentHandler(bestAttemptContent)
                    }
                } receiveValue: { response in
                    print(response)
                    bestAttemptContent.title = "\(bestAttemptContent.title) [saved]"
                    contentHandler(bestAttemptContent)
                }.store(in: &self.subs)
            }.store(in: &subs)
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
