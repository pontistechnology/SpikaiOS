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
        print("SSE: init")
    }
    
    deinit {
        print("SSE: deinit")
    }
}

extension SSE {
    
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

extension SSE {
    
    func syncAndStartSSE() {
        syncRooms()
    }
    
    func startSSEConnection(){
        eventSource?.connect()
    }
    
    func setupSSE() {
        guard let accessToken = repository.getAccessToken(),
              let serverURL = URL(string: Constants.Networking.baseUrl
                                  + "api/sse/"
                                  + "?accesstoken=" + accessToken)
        else {
            print("SSE: AccessToken is missing.")
            return }
        eventSource = EventSource(url: serverURL)
        
        eventSource?.onOpen {
            print("SSE: CONNECTED")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            print("SSE: DISCONNECTED")
//            guard reconnect ?? false else { return } // if server wants to control reconnecting
            
            let retryTime = self?.eventSource?.retryTime ?? 1500
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
            print("SSE: without decoding: ", data ?? "")
            guard let self = self,
                  let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData),
                  let type = sseNewMessage.type
            else {
                print("SSE: decoding error")
                return
            }
            switch type {
            case .newMessage:
                guard let message = sseNewMessage.message else { return }
                print("SSE: new message _ ", message)
                self.saveMessages([message])
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                print("SSE: MESSAGE RECORD ON SSE: ", record)
                self.saveMessageRecords([record])
            case .newRoom:
                guard let room = sseNewMessage.room else { return }
                print("SSE: NEW ROOM: ", room)
                self.saveLocalRooms([room])
            case .updateRoom:
                guard let room = sseNewMessage.room else { return }
                print("SSE: UPDATE ROOM: ", room)
                self.saveLocalRooms([room])
            default:
                break
            }
        }
    }
}

// MARK: - Sync api calls

extension SSE {
    func syncRooms() {
        repository.syncRooms(timestamp: repository.getSyncTimestamp(for: .rooms)).sink { c in
            print("SSE: sync rooms c: ", c)
        } receiveValue: { [weak self] response in
            print("SSE: sync rooms response: ", response)
            guard let rooms = response.data?.rooms else { return }
            self?.saveLocalRooms(rooms, isSync: true)
        }.store(in: &subs)
    }
    
    // TODO: - check local DB for all roomIds, and fetch the missing ones
    func syncMessages() {
        repository.syncMessages(timestamp: repository.getSyncTimestamp(for: .messages)).sink { c in
            print("SSE: sync messages c: ", c)
        } receiveValue: { [weak self] response in
            print("SSE: sync messages response: ", response)
            guard let self = self,
                  let messages = response.data?.messages
            else { return }
            self.saveMessages(messages, isSync: true)
        }.store(in: &subs)
    }
    
    func syncUsers() {
        repository.syncUsers(timestamp: repository.getSyncTimestamp(for: .users)).sink { [weak self] c in
            print("SSE: sync users C: ", c)
        } receiveValue: { [weak self] response in
            print("SSE: sync users response: ", response)
            guard let users = response.data?.users else { return }
            self?.saveUsers(users, isSync: true)
        }.store(in: &subs)
    }
    
    func syncMessageRecords() {
        repository.syncMessageRecords(timestamp: repository.getSyncTimestamp(for: .messageRecords)).sink { [weak self] c in
            print("SSE: sync message records C: ", c)
        } receiveValue: { [weak self] response in
            print("SSE: sync message records response", response)
            guard let self = self else { return }
            guard let records = response.data?.messageRecords else { return }
            print("SSE: records before: ", records.count)
            self.saveMessageRecords(records, isSync: true)
        }.store(in: &subs)
    }
}

// MARK: - Saving to local database

extension SSE {
    func saveUsers(_ users: [User], isSync: Bool = false) {
        repository.saveUsers(users).sink { c in
            print("SSE: save _ c: ", c)
        } receiveValue: { [weak self] users in
            print("SSE: save users success")
            if isSync {
                if !users.isEmpty {
                    let timestamp = users.max{ ($0.createdAt ?? 0) < ($1.createdAt ?? 0) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .users, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.users)
            }
        }.store(in: &subs)
    }
    
    func saveLocalRooms(_ rooms: [Room], isSync: Bool = false) {
        repository.saveLocalRooms(rooms: rooms).sink { c in
            print("SSE: save rooms c: ", c)
            switch c {
            case .finished:
                break
            case .failure(_):
                break
            }
        } receiveValue: { [weak self] rooms in
            print("SSE: save rooms success")
            if isSync {
                if !rooms.isEmpty {
                    let timestamp = rooms.max{ ($0.createdAt ?? 0) < ($1.createdAt ?? 0) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .rooms, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.rooms)
            }
        }.store(in: &subs)
    }
    
    func saveMessages(_ messages: [Message], isSync: Bool = false) {
        repository.saveMessages(messages).sink { c in
            print("SSE: save message c: ", c)
        } receiveValue: { [weak self] messages in
            print("SSE: SAVED MESSAGES: ", messages.count)
            if isSync {
                self?.repository.setSyncTimestamp(for: .messages, timestamp: Date().currentTimeMillis())
                if !messages.isEmpty {
                    let timestamp = messages.max{ ($0.createdAt ?? 0) < ($1.createdAt ?? 0) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .messages, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.messages)
            }
            // TODO: - call delivered
            self?.sendDeliveredStatus(messages: messages)
            if let lastMessage = messages.last {
                self?.getMessageNotificationInfo(message: lastMessage)
            }
        }.store(in: &subs)
    }
    
    func saveMessageRecords(_ records: [MessageRecord], isSync: Bool = false) {
        repository.saveMessageRecords(records).sink { c in
            print("SSE: save message records c: ", c)
        } receiveValue: { [weak self] records in
            print("SSE: saved records")
            if isSync {
                self?.repository.setSyncTimestamp(for: .messageRecords, timestamp: Date().currentTimeMillis())
                if !records.isEmpty {
                    let timestamp = records.max{ ($0.createdAt ?? 0) < ($1.createdAt ?? 0) }?.createdAt ?? 0
                    self?.repository.setSyncTimestamp(for: .messageRecords, timestamp: timestamp)
                }
                self?.finishedSyncPublisher.send(.messageRecords)
            }
        }.store(in: &subs)
    }
}

// MARK: - sending delivered ids
extension SSE {
    
    func sendDeliveredStatus(messages: [Message]) {
        print("message id in sse: ", messages)
        windowWorkItem?.cancel()
        windowWorkItem = nil
        
        repository.sendDeliveredStatus(messageIds: messages.compactMap{$0.id}).sink { c in
            
        } receiveValue: { [weak self] response in
            print("SSE: send delivered status sse response: ", response)
        }.store(in: &subs)
    }
}

// MARK: - Notification show

extension SSE {
    
    func getMessageNotificationInfo(message: Message) {
        repository.getNotificationInfoForMessage(message).sink { c in
            
        } receiveValue: { [weak self] info in
            self?.showNotification(imageUrl: info.photoUrl, name: info.title, text: info.messageText)
        }.store(in: &subs)

    }
    
    func showNotification(imageUrl: String?, name: String, text: String) {
        DispatchQueue.main.async {
            
            guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
            else { return }
            for window in windowScene.windows {
                for vc in window.rootViewController?.children ?? [] {
                    if vc is CurrentChatViewController {
                        return
                    }
                }
            }
            
            self.alertWindow = nil
            let alertWindow = UIWindow(windowScene: windowScene)
            alertWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
            alertWindow.rootViewController = UIViewController()
            alertWindow.isHidden = false
            alertWindow.overrideUserInterfaceStyle = .light // TODO: check colors
            
            let messageNotificationView = MessageNotificationView(imageUrl: URL(string: imageUrl ?? ""), senderName: name, textOrDescription: text)
            
            alertWindow.rootViewController?.view.addSubview(messageNotificationView)
            messageNotificationView.anchor(top: alertWindow.rootViewController?.view.safeAreaLayoutGuide.topAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
            messageNotificationView.centerXToSuperview()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
            messageNotificationView.addGestureRecognizer(tapGesture)
           
            self.alertWindow = alertWindow
            
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.alertWindow = nil
            }
            self.windowWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
        }
        
    }
    
    @objc func handleGesture(_ sender: UITapGestureRecognizer) {
        // TODO: handle tap
        alertWindow = nil
    }
}
