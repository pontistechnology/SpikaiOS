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
    var currentMessage: Message?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let jsonData = (bestAttemptContent.userInfo["message"] as? String)?.data(using: .utf8),
                  let message = try? JSONDecoder().decode(Message.self, from: jsonData),
                  let roomId = message.roomId
            else {
                bestAttemptContent.title = "DECODING ERROR"
                contentHandler(bestAttemptContent)
                return
            }
            
            currentMessage = message
//            guard let id = message.id else { return }
//            sendDeliveredStatus(messageIds: [id])
            checkLocalRoom(roomId: roomId)
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

extension NotificationService {
    
    func sendDeliveredStatus(messageIds: [Int]) {
        repository.sendDeliveredStatus(messageIds: messageIds).sink { c in
            
        } receiveValue: { response in
            guard let bestAttemptContent = self.bestAttemptContent,
                  let contentHandler = self.contentHandler
            else { return }
            contentHandler(bestAttemptContent)
        }.store(in: &subs)
    }
    
    func checkLocalRoom(roomId: Int) {
        repository.checkLocalRoom(withId: roomId).sink { [weak self] c in
            switch c {
                
            case .finished:
                break
            case .failure(_):
                self?.checkOnlineRoom(roomId: roomId)
                break
            }
        } receiveValue: { [weak self] room in
            guard let currentMessage = self?.currentMessage else { return }
            self?.saveMessage(message: currentMessage, room: room)
        }.store(in: &subs)
    }
    
    func checkOnlineRoom(roomId: Int) {
        repository.checkOnlineRoom(forRoomId: roomId).sink { completion in
            switch completion {
                
            case .finished:
                break
            case .failure(_):
                // TODO: handle error
                break
            }
        } receiveValue: { [weak self] response in
            guard let room = response.data?.room else { return }
            self?.saveLocalRoom(room: room)
        }.store(in: &subs)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveLocalRoom(room: room).sink { completion in
            switch completion {
                
            case .finished:
                break
            case .failure(_):
                break
            }
        } receiveValue: { [weak self] room in
            self?.checkLocalRoom(roomId: room.id)
        }.store(in: &subs)
    }
    
    func saveMessage(message: Message, room: Room) {
        repository.saveMessage(message: message, roomId: room.id).sink { [weak self] c in
            guard let self = self else { return }
            switch c {
                
            case .finished:
                break
            case let .failure(error):
                guard let bestAttemptContent = self.bestAttemptContent,
                      let contentHandler = self.contentHandler
                else { return }
                
                bestAttemptContent.title = "Saving Error: \(error)"
                contentHandler(bestAttemptContent)
            }
        } receiveValue: { message in
            guard let senderRoomUser = room.users?.first(where: { roomUser in
                roomUser.user?.id == message.fromUserId
            }),
                  let senderName = senderRoomUser.user?.getDisplayName(),
                  let bestAttemptContent = self.bestAttemptContent
            else { return }
            
            bestAttemptContent.title = senderName
            guard let id = self.currentMessage?.id else {
                return
            }
            self.sendDeliveredStatus(messageIds: [id])
        }.store(in: &subs)

    }
}
