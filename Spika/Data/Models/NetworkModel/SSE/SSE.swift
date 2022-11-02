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
    private var windowWorkItem: DispatchWorkItem?
    private var eventSource: EventSource?
    private var alertWindow: UIWindow?
    private let repository: Repository
    private let coordinator: Coordinator
    private var subs = Set<AnyCancellable>()
    
    private let finishedSyncPublisher = PassthroughSubject<SyncType, Never>()
    
    init(repository: Repository, coordinator: Coordinator) {
        self.repository = repository
        self.coordinator = coordinator
        setupBindings()
        setupSSE()
    }
    
    func syncAndStartSSE() {
//        WindowManager.shared.indicatorColorPublisher.send(.appOrange)
        if eventSource == nil {
            setupSSE()
        }
        syncRooms()
    }
    
    func stopSSE() {
        eventSource?.disconnect()
    }
}

private extension SSE {
    
    func setupBindings() {
        finishedSyncPublisher.sink { [weak self] finished in
            guard let self = self else { return }
            switch finished {
            case .users:
                self.syncMessages()
            case .rooms:
                self.syncUsers()
            case .messages:
                self.syncMessageRecords()
            case .messageRecords:
                self.startSSEConnection()
            }
        }.store(in: &subs)
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
        
        eventSource?.onOpen {
//            WindowManager.shared.indicatorColorPublisher.send(.appGreen)
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
//            WindowManager.shared.indicatorColorPublisher.send(.appRed)
            self?.syncAndStartSSE()

//            guard reconnect ?? false else { return }
//            if server wants to control reconnecting
//            let retryTime = self?.eventSource?.retryTime ?? 1500
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
            guard let self = self,
                  let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData),
                  let type = sseNewMessage.type
            else {
                return
            }
            switch type {
            case .newMessage:
                guard let message = sseNewMessage.message else { return }
                self.saveMessages([message])
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                self.saveMessageRecords([record]) // TODO: - delay or something
            case .newRoom, .updateRoom:
                guard let room = sseNewMessage.room else { return }
                self.saveLocalRooms([room])
            default:
                break
            }
        }
    }
}

// MARK: - Sync api calls

private extension SSE {
    func syncRooms() {
        repository.syncRooms(timestamp: repository.getSyncTimestamp(for: .rooms)).sink { c in
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            self?.saveLocalRooms(rooms, isSync: true)
        }.store(in: &subs)
    }
    
    // TODO: - check local DB for all roomIds, and fetch the missing ones
    func syncMessages() {
        repository.syncMessages(timestamp: repository.getSyncTimestamp(for: .messages)).sink { c in
        } receiveValue: { [weak self] response in
            guard let self = self,
                  let messages = response.data?.messages
            else { return }
            self.saveMessages(messages, isSync: true)
        }.store(in: &subs)
    }
    
    func syncUsers() {
        repository.syncUsers(timestamp: repository.getSyncTimestamp(for: .users)).sink { [weak self] c in
        } receiveValue: { [weak self] response in
            guard let users = response.data?.users else { return }
            self?.saveUsers(users, isSync: true)
        }.store(in: &subs)
    }
    
    func syncMessageRecords() {
        repository.syncMessageRecords(timestamp: repository.getSyncTimestamp(for: .messageRecords)).sink { [weak self] c in
        } receiveValue: { [weak self] response in
            guard let self = self,
                  let records = response.data?.messageRecords
            else { return }
            self.saveMessageRecords(records, isSync: true)
        }.store(in: &subs)
    }
}

// MARK: - Saving to local database

private extension SSE {
    func saveUsers(_ users: [User], isSync: Bool = false) {
        repository.saveUsers(users).sink { c in
//            print("SSE: save _ c: ", c)
        } receiveValue: { [weak self] users in
//            print("SSE: save users success")
            if isSync {
                if !users.isEmpty {
                    let timestamp = users.max{ $0.createdAt < $1.createdAt }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .users, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.users)
            }
        }.store(in: &subs)
    }
    
    func saveLocalRooms(_ rooms: [Room], isSync: Bool = false) {
        repository.saveLocalRooms(rooms: rooms).sink { c in
//            print("SSE: save rooms c: ", c)
            switch c {
            case .finished:
                break
            case .failure(_):
                break
            }
        } receiveValue: { [weak self] rooms in
//            print("SSE: save rooms success")
            if isSync {
                if !rooms.isEmpty {
                    let timestamp = rooms.max{ ($0.createdAt) < ($1.createdAt) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .rooms, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.rooms)
            }
        }.store(in: &subs)
    }
    
    func saveMessages(_ messages: [Message], isSync: Bool = false) {
        repository.saveMessages(messages).sink { c in
//            print("SSE: save message c: ", c)
        } receiveValue: { [weak self] messages in
//            print("SSE: SAVED MESSAGES: ", messages.count)
            if isSync {
                let currentTimestamp = Date().currentTimeMillis()
                let maxTimestamp = messages.max(by: {$0.createdAt < $1.createdAt})?.createdAt ?? currentTimestamp
                let minTimestamp = messages.min(by: {$0.createdAt < $1.createdAt})?.createdAt ?? currentTimestamp
                
                self?.repository.setSyncTimestamp(for: .messages, timestamp: maxTimestamp)
                self?.repository.setSyncTimestamp(for: .messageRecords, timestamp: minTimestamp)
                self?.finishedSyncPublisher.send(.messages)
            } else if let lastMessage = messages.last {
                self?.getMessageNotificationInfo(message: lastMessage)
            }
            self?.sendDeliveredStatus(messages: messages)
        }.store(in: &subs)
    }
    
    func saveMessageRecords(_ records: [MessageRecord], isSync: Bool = false) {
        print("SSE: message records recieved: ", records.count)
        repository.saveMessageRecords(records).sink { c in
//            print("SSE: save message records c: ", c)
        } receiveValue: { [weak self] records in
//            print("SSE: saved records: ", records.count)
            if isSync {
                self?.finishedSyncPublisher.send(.messageRecords)
            }
        }.store(in: &subs)
    }
}

// MARK: - sending delivered ids
private extension SSE {
    
    func sendDeliveredStatus(messages: [Message]) {
//        print("message id in sse: ", messages)
        
        
        repository.sendDeliveredStatus(messageIds: messages.compactMap{$0.id}).sink { c in
            
        } receiveValue: { [weak self] response in
//            print("SSE: send delivered status sse response: ", response)
        }.store(in: &subs)
    }
}

// MARK: - Notification show

private extension SSE {
    
    func getMessageNotificationInfo(message: Message) {
        repository.getNotificationInfoForMessage(message).sink { c in
            
        } receiveValue: { [weak self] info in
            self?.showNotification(info: info)
        }.store(in: &subs)
    }
    
    func showNotification(info: MessageNotificationInfo) {
        DispatchQueue.main.async {
//            WindowManager.shared.notificationPublisher.send(.show(info: info))
        }
    }
}
