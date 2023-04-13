//
//  SSE.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.04.2022..
//

import Combine
import CoreData
import IKEventSource
import UIKit

class SSE {
    private var eventSource: EventSource?
    private let repository: Repository
    private let coordinator: Coordinator
    private var subs = Set<AnyCancellable>()
    
    init(repository: Repository, coordinator: Coordinator) {
        self.repository = repository
        self.coordinator = coordinator
        setupSSE()
    }
    
    func startSSEAndSync() {
        if eventSource == nil {
            setupSSE()
        }
        repository.refreshUnreadCounts()
        startSSEConnection()
    }
    
    func stopSSE() {
        eventSource?.disconnect()
    }
    
    private func startSyncs() {
        repository.syncRooms()
        repository.syncUsers()
        repository.syncMessages()
        repository.syncBlockedList()
        repository.syncMessageRecords()
    }
}

private extension SSE {
    
    func startSSEConnection(){
        if eventSource?.readyState == .closed {
            eventSource?.connect()
        }
    }
    
    func setupSSE() {
        guard let accessToken = repository.getAccessToken(),
              let serverURL = URL(string: Constants.Networking.baseUrl
                                  + "api/sse/"
                                  + "?accesstoken=" + accessToken)
        else {
//            print("SSE: AccessToken is missing.")
            return
        }
        eventSource = EventSource(url: serverURL)
        
        eventSource?.onOpen { [weak self] in
            self?.changeIndicatorColor(to: .appGreen)
            self?.startSyncs()
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            self?.changeIndicatorColor(to: .appRed)
            guard UIApplication.shared.applicationState == .active else { return }
            self?.startSSEAndSync()
//            guard reconnect ?? false else { return }
//            if server wants to control reconnecting
//            let retryTime = self?.eventSource?.retryTime ?? 1500
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
            print("SSE DATA: ", data) // this is for see actual data
            guard let self,
                  let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData),
                  let type = sseNewMessage.type
            else {
                return
            }
            switch type {
            case .newMessage:
                guard let message = sseNewMessage.message else { return }
                self.saveMessage(message)
                self.repository.refreshUnreadCounts()
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                _ = self.repository.saveMessageRecords([record])
                guard let newDetails = sseNewMessage.messageRecord?.message else { return }
                self.updateMessage(messageCounts: newDetails)
            case .newRoom, .updateRoom:
                guard let room = sseNewMessage.room else { return }
                _ = self.repository.saveLocalRooms(rooms: [room])
            case .seenRoom:
                guard let roomId = sseNewMessage.roomId else { return }
                self.repository.updateUnreadCountToZeroFor(roomId: roomId)
            default:
                break
            }
        }
    }
}

private extension SSE {
   func updateMessage(messageCounts: SomeMessageDetails) {
        repository.updateMessageSeenDeliveredCount(messageId: messageCounts.id, seenCount: messageCounts.seenCount, deliveredCount: messageCounts.deliveredCount)
    }
}

// MARK: - Notification show

private extension SSE {
    
    func saveMessage(_ message: Message) {
        repository.saveMessages([message]).sink { _ in
            
        } receiveValue: { [weak self] isSaved in
            guard let id = message.id else { return }
            self?.repository.sendDeliveredStatus(messageIds: [id])
            self?.getMessageNotificationInfo(message: message)
        }.store(in: &subs)
    }
    
    func getMessageNotificationInfo(message: Message) {
        guard message.fromUserId != repository.getMyUserId() else { return }
        repository.getNotificationInfoForMessage(message).sink { _ in

        } receiveValue: { [weak self] info in
            if !info.isRoomMuted {
                self?.showNotification(info: info)                
            }
        }.store(in: &subs)
    }
}

private extension SSE {
    func changeIndicatorColor(to color: UIColor) {
        (coordinator as? AppCoordinator)?.changeIndicatorColor(to: color)
    }
    
    func showNotification(info: MessageNotificationInfo) {
        (coordinator as? AppCoordinator)?.showNotification(info: info)
    }
}
