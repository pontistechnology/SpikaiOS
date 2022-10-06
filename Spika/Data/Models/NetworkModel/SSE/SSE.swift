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
        print("SSE init")
        setupBindings()
    }
    
    deinit {
        print("SSE deinit")
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
                break // start sse
            }
        }.store(in: &subs)
    }
}

extension SSE {
    
    func syncAndStartSSE() {
        syncRooms()
    }
    
    func startSSEConnection(){
        setupSSE()
        eventSource?.connect()
    }
    
    func setupSSE() {
        guard let accessToken = repository.getAccessToken(),
              let serverURL = URL(string: Constants.Networking.baseUrl
                                  + "api/sse/"
                                  + "?accesstoken=" + accessToken)
        else { return }
        eventSource = EventSource(url: serverURL)
        
        eventSource?.onOpen {
            print("CONNECTED")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            print("DISCONNECTED")
//            guard reconnect ?? false else { return }
            
//            let retryTime = self?.eventSource?.retryTime ?? 3000
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
//                self?.eventSource?.connect()
//            }
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
            print("SSE without decoding: ", data ?? "")
            guard let self = self,
                  let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData),
                  let type = sseNewMessage.type
            else {
                print("SSE decoding error")
                return
            }
            switch type {
            case .newMessage:
                guard let message = sseNewMessage.message else { return }
//                self.newMessages.send(message)
            case .newMessageRecord:
                guard let record = sseNewMessage.messageRecord else { return }
                print("MESSAGE RECORD ON SSE: ", record)
                self.saveMessageRecord(record)
            default:
                break
            }
        }
    }
}

extension SSE {
    func syncRooms() {
        repository.syncRooms(timestamp: repository.getSyncTimestamp(for: .rooms)).sink { c in
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            self?.repository.saveLocalRooms(rooms: rooms).sink { _ in
                
            } receiveValue: { [weak self] rooms in
                self?.repository.setSyncTimestamp(for: .rooms)
            }.store(in: &self!.subs)

        }.store(in: &subs)
    }
    
    func syncMessages() {
        repository.syncMessages(timestamp: repository.getSyncTimestamp(for: .messages)).sink { c in
        } receiveValue: { [weak self] response in
            print("sync messages: ", response)
            guard let self = self,
                  let messages = response.data?.messages
            else { return }
            print("messages before: ", messages.count)
            self.saveMessages(messages)
        }.store(in: &subs)
    }
    
    func syncUsers() {
        repository.syncUsers(timestamp: repository.getSyncTimestamp(for: .users)).sink { [weak self] c in
            print("users C: ", c)
        } receiveValue: { [weak self] response in
            print("sync users: ", response)
            guard let users = response.data?.users else { return }
            self?.repository.setSyncTimestamp(for: .users)
            self?.repository.saveUsers(users).sink(receiveCompletion: { [weak self] c in
                print("save users sync c: ", c)
            }, receiveValue: { users in
                
            }).store(in: &self!.subs)
        }.store(in: &subs)
    }
    
    func syncMessageRecords() {
        repository.syncMessageRecords(timestamp: repository.getSyncTimestamp(for: .messageRecords)).sink { [weak self] c in
            print("sync message records C: ", c)
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            guard let records = response.data?.messageRecords else { return }
            self.repository.setSyncTimestamp(for: .messageRecords)
            print("records before: ", records.count)
            
            records.forEach { record in
                self.repository.saveMessageRecord(messageRecord: record).sink { c in
                } receiveValue: { record in
                    print("sync saved message record: ", record)
                    
                }.store(in: &self.subs)
            }
        }.store(in: &subs)
    }
}

extension SSE {
    
    func sendDeliveredStatus(messages: [Message]) {
        print("message id in sse: ", messages)
        windowWorkItem?.cancel()
        windowWorkItem = nil
        showNotification(imageUrl: URL(string: "noUrl"),
                                          name: "no name",
                               text: messages.last?.body?.text ?? "no text")
        
        
        repository.sendDeliveredStatus(messageIds: messages.compactMap{$0.id}).sink { c in
            
        } receiveValue: { [weak self] response in
            // TODO: fetch information, save message records
            print("send delivered status sse response: ", response)
        }.store(in: &subs)
    }
    
    func checkLocalRoom(message: Message) {
        guard let roomId = message.roomId else { return }
        repository.checkLocalRoom(withId: roomId).sink { [weak self] c in
            switch c {
                
            case .finished:
                break
            case .failure(_):
//                self?.messagesWithoutLocalRoom.send(message)
                break
            }
        } receiveValue: { [weak self] room in
//            self?.messagesWithLocalRoom.send(message)
        }.store(in: &subs)
    }
    
    
    func checkOnlineRoom(message: Message) {
        guard let roomId = message.roomId else { return }
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
            self?.saveLocalRooms([room])
        }.store(in: &subs)
    }
    
    func saveLocalRooms(_ rooms: [Room]) {
        repository.saveLocalRooms(rooms: rooms).sink { completion in
            switch completion {
                
            case .finished:
                break
            case .failure(_):
                break
            }
        } receiveValue: { [weak self] rooms in
//            self?.messagesWithLocalRoom.send(message)
        }.store(in: &subs)
    }
    
    func saveMessages(_ messages: [Message]) {
        repository.saveMessages(messages).sink { c in
            
        } receiveValue: { messages in
            print("SAVED MESSAGES: ", messages.count)
            // TODO: - call delivered
        }.store(in: &subs)
    }
    
    func saveMessageRecord(_ record: MessageRecord) {
        repository.saveMessageRecord(messageRecord: record).sink { c in
        } receiveValue: { record in
        }.store(in: &self.subs)
    }
}

extension SSE {
    
    func showNotification(imageUrl: URL?, name: String, text: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
            else { return }
            
            self.alertWindow = nil
            let alertWindow = UIWindow(windowScene: windowScene)
            alertWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
            alertWindow.rootViewController = UIViewController()
            alertWindow.isHidden = false
            alertWindow.overrideUserInterfaceStyle = .light // TODO: check colors
            
            let messageNotificationView = MessageNotificationView(imageUrl: imageUrl, senderName: name, textOrDescription: text)
            
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
