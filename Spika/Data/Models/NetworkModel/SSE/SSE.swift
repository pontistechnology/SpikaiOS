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
        startSSEConnection()
    }
    
    func stopSSE() {
        eventSource?.disconnect()
    }
    
    private func startSyncs() {
        syncRooms()
        syncUsers()
        syncMessages()
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
            self?.startSSEAndSync()
//            guard reconnect ?? false else { return }
//            if server wants to control reconnecting
//            let retryTime = self?.eventSource?.retryTime ?? 1500
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
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
                self.saveMessages([message])
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                self.saveMessageRecords([record])
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
    func syncBlockedList() {
        repository.getBlockedUsers()
            .sink { _ in
            } receiveValue: { [weak self] response in
                self?.repository.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subs)
    }
    
    func syncRooms() {
        repository.syncRooms(timestamp: repository.getSyncTimestamp(for: .rooms)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            self?.saveLocalRooms(rooms, isSync: true)
        }.store(in: &subs)
    }
    
    // TODO: - dbr check local DB for all roomIds, and fetch the missing ones
    func syncMessages() {
        repository.syncMessages(timestamp: repository.getSyncTimestamp(for: .messages)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let self,
                  let messages = response.data?.messages
            else { return }
            self.saveMessages(messages, isSync: true)
        }.store(in: &subs)
    }
    
    func syncUsers() {
        repository.syncUsers(timestamp: repository.getSyncTimestamp(for: .users)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let users = response.data?.users else { return }
            self?.saveUsers(users, isSync: true)
        }.store(in: &subs)
    }
    
    func syncMessageRecords() {
        repository.syncMessageRecords(timestamp: repository.getSyncTimestamp(for: .messageRecords)).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] response in
            guard let self,
                  let records = response.data?.messageRecords
            else { return }
            self.saveMessageRecords(records, isSync: true)
        }.store(in: &subs)
    }
}

// MARK: - Saving to local database

private extension SSE {
    func saveUsers(_ users: [User], isSync: Bool = false) {
        repository.saveUsers(users).sink { [weak self] completion in
            self?.checkError(completion: completion)
//            print("SSE: save _ c: ", c)
        } receiveValue: { [weak self] users in
//            print("SSE: save users success")
            if isSync {
                if !users.isEmpty {
                    let timestamp = users.max{ $0.createdAt < $1.createdAt }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .users, timestamp: timestamp)
                }
            }
        }.store(in: &subs)
    }
    
    func saveLocalRooms(_ rooms: [Room], isSync: Bool = false) {
        repository.saveLocalRooms(rooms: rooms).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] rooms in
            if isSync {
                if !rooms.isEmpty {
                    let timestamp = rooms.max{ ($0.createdAt) < ($1.createdAt) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .rooms, timestamp: timestamp)
                }
            }
        }.store(in: &subs)
    }
    
    func saveMessages(_ messages: [Message], isSync: Bool = false) {
        repository.saveMessages(messages).sink { [weak self] completion in
            self?.checkError(completion: completion)
//            print("SSE: save message c: ", c)
        } receiveValue: { [weak self] messages in
//            print("SSE: SAVED MESSAGES: ", messages.count)
            if isSync {
                let currentTimestamp = Date().currentTimeMillis()
                let maxTimestamp = messages.max(by: {$0.createdAt < $1.createdAt})?.createdAt ?? currentTimestamp
                let minTimestamp = messages.min(by: {$0.createdAt < $1.createdAt})?.createdAt ?? currentTimestamp
                
                self?.repository.setSyncTimestamp(for: .messages, timestamp: maxTimestamp)
                self?.repository.setSyncTimestamp(for: .messageRecords, timestamp: minTimestamp)
            } else if let lastMessage = messages.last {
                self?.getMessageNotificationInfo(message: lastMessage)
            }
            self?.sendDeliveredStatus(messages: messages)
        }.store(in: &subs)
    }
    
    func saveMessageRecords(_ records: [MessageRecord], isSync: Bool = false) {
        print("SSE: message records recieved: ", records.count)
        repository.saveMessageRecords(records).sink { [weak self] completion in
            self?.checkError(completion: completion)
        } receiveValue: { [weak self] records in
        }.store(in: &subs)
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
