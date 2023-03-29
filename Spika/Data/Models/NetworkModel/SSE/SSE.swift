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
        getUnreadCounts()
        startSSEConnection()
    }
    
    func stopSSE() {
        eventSource?.disconnect()
    }
    
    private func startSyncs() {
        syncRooms()
        syncUsers()
        syncModifiedMessages()
        syncUndeliveredMessages()
        syncBlockedList()
        syncMessageRecords()
    }
}
// TIMESTAMPS ARE WRONG HANDLED
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
//            print("SSE DATA: ", data) // this is for see actual data
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
                self.saveMessages([message], syncTimestamp: nil)
                self.getUnreadCounts()
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                self.saveMessageRecords([record], syncTimestamp: nil)
                guard let newDetails = sseNewMessage.messageRecord?.message else { return }
                self.updateMessage(messageCounts: newDetails)
            case .newRoom, .updateRoom:
                guard let room = sseNewMessage.room else { return }
                self.saveLocalRooms([room], syncTimestamp: nil)
            case .seenRoom:
                guard let roomId = sseNewMessage.roomId else { return }
                self.repository.updateUnreadCounts(unreadCounts: [UnreadCount(roomId: roomId, unreadCount: 0)])
            default:
                break
            }
        }
    }
}

// MARK: - Sync api calls

private extension SSE {
    func syncBlockedList() {
        repository.getBlockedUsers()
            .sink { _ in
            } receiveValue: { [weak self] response in
                self?.repository.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subs)
    }
    
    func syncRooms() {
        let timestampNow = Date().currentTimeMillis()
        repository.syncRooms(timestamp: repository.getSyncTimestamp(for: .rooms)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            self?.saveLocalRooms(rooms, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    // TODO: - dbr check local DB for all roomIds, and fetch the missing ones
    func syncModifiedMessages() {
        let timestampNow = Date().currentTimeMillis()
        repository.syncModifiedMessages(timestamp: repository.getSyncTimestamp(for: .messages)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let self,
                  let messages = response.data?.messages
            else { return }
            self.saveMessages(messages, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    func syncUndeliveredMessages() {
        repository.syncUndeliveredMessages().sink { c in
            
        } receiveValue: { [weak self] response in
            guard let self,
                  let messages = response.data?.messages
            else { return }
            self.saveMessages(messages, syncTimestamp: nil)
        }.store(in: &subs)
    }
    
    func syncUsers() {
        let timestampNow = Date().currentTimeMillis()
        repository.syncUsers(timestamp: repository.getSyncTimestamp(for: .users)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let users = response.data?.users else { return }
            self?.saveUsers(users, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    func syncMessageRecords() {
        let timestampNow = Date().currentTimeMillis()
        repository.syncMessageRecords(timestamp: repository.getSyncTimestamp(for: .messageRecords)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let self,
                  let records = response.data?.messageRecords
            else { return }
            self.saveMessageRecords(records, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
}

// MARK: - Saving to local database

private extension SSE {
    func saveUsers(_ users: [User], syncTimestamp: Int64?) {
        repository.saveUsers(users).sink { [weak self] completion in
            self?.checkError(completion: completion)
//            print("SSE: save _ c: ", c)
        } receiveValue: { [weak self] users in
//            print("SSE: save users success")
            guard let syncTimestamp else { return }
            self?.repository.setSyncTimestamp(for: .users, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
    
    func saveLocalRooms(_ rooms: [Room], syncTimestamp: Int64?) {
        repository.saveLocalRooms(rooms: rooms).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] rooms in
            guard let syncTimestamp else { return }
            self?.repository.setSyncTimestamp(for: .rooms, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
    
    func saveMessages(_ messages: [Message], syncTimestamp: Int64?) {
        repository.saveMessages(messages).sink { [weak self] completion in
            self?.checkError(completion: completion)
//            print("SSE: save message c: ", c)
        } receiveValue: { [weak self] messages in
//            print("SSE: SAVED MESSAGES: ", messages.count)
            if let syncTimestamp {
                self?.repository.setSyncTimestamp(for: .messages, timestamp: syncTimestamp)
            } else {
                if let lastMessage = messages.last {
                    self?.getMessageNotificationInfo(message: lastMessage)
                }
            }
            self?.sendDeliveredStatus(messages: messages)
        }.store(in: &subs)
    }
    
    func saveMessageRecords(_ records: [MessageRecord], syncTimestamp: Int64?) {
        print("SSE: message records recieved: ", records.count)
        repository.saveMessageRecords(records).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] records in
            guard let syncTimestamp else { return }
            self?.repository.setSyncTimestamp(for: .messageRecords, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
    
    func updateMessage(messageCounts: SomeMessageDetails) {
        repository.updateMessageSeenDeliveredCount(messageId: messageCounts.id, seenCount: messageCounts.seenCount, deliveredCount: messageCounts.deliveredCount)
    }
}

// MARK: - sending delivered ids
private extension SSE {
    
    func sendDeliveredStatus(messages: [Message]) {
        repository.sendDeliveredStatus(messageIds: messages.compactMap{$0.id})
            .sink { c in
            
        } receiveValue: { response in
//            print("SSE: send delivered status sse response: ", response)
        }.store(in: &subs)
    }
    
    func getUnreadCounts() {
        repository.getUnreadCounts().sink { c in
            
        } receiveValue: { [weak self] response in
            guard let counts = response.data?.unreadCounts else { return }
            self?.repository.updateUnreadCounts(unreadCounts: counts)
        }.store(in: &subs)
    }
}

// MARK: - Notification show

private extension SSE {
    
    func getMessageNotificationInfo(message: Message) {
        repository.getNotificationInfoForMessage(message).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] info in
            self?.showNotification(info: info)
        }.store(in: &subs)
    }
}

private extension SSE {
    func checkError(completion: Subscribers.Completion<any Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print("SSE FAILURE SOMEWHERE: ", error)
            changeIndicatorColor(to: .appRed)
        }
    }
    
    func changeIndicatorColor(to color: UIColor) {
        (coordinator as? AppCoordinator)?.changeIndicatorColor(to: color)
    }
    
    func showNotification(info: MessageNotificationInfo) {
        (coordinator as? AppCoordinator)?.showNotification(info: info)
    }
}
