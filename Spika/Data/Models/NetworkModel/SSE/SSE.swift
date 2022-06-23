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
    let dispatchGroup = DispatchGroup()
    var eventSource: EventSource?
    var alertWindow: UIWindow?
    let repository: Repository
    let coordinator: Coordinator
    var subs = Set<AnyCancellable>()
    let userDefaults = UserDefaults(suiteName: Constants.Strings.appGroupName)!

    var currentMessage: Message?
    var senderRoom: Room?
    
    init(repository: Repository, coordinator: Coordinator) {
        self.repository = repository
        self.coordinator = coordinator
        print("SSE init")
    }
    
    deinit {
        print("SSE deinit")
    }
    
    func syncAndStartSSE() {
        
        repository.printAllMessages()
        
        dispatchGroup.enter()
        repository.syncRooms(timestamp: repository.getRoomsSyncTimestamp()).sink { [weak self] c in
            print("C: ", c)
            self?.dispatchGroup.leave()
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            print("SYNCED ROOMS: ", rooms)
            self?.repository.saveLocalRooms(rooms: rooms).sink { [weak self] c in
                print(c)
            } receiveValue: { [weak self] rooms in
                self?.repository.setRoomsSyncTimestamp(Date().currentTimeMillis())
            }.store(in: &self!.subs)

        }.store(in: &subs)
        
        dispatchGroup.enter()
        repository.syncUsers(timestamp: repository.getUsersSyncTimestamp()).sink { [weak self] c in
            print("users C: ", c)
            self?.dispatchGroup.leave()
        } receiveValue: { [weak self] response in
            print("sync users: ", response)
            guard let users = response.data?.users else {
                return
            }
            self?.repository.setUsersSyncTimestamp(Date().currentTimeMillis())
            self?.dispatchGroup.enter()
            self?.repository.saveUsers(users).sink(receiveCompletion: { [weak self] c in
                print("save users sync c: ", c)
                self?.dispatchGroup.leave()
            }, receiveValue: { users in
                
            }).store(in: &self!.subs)
        }.store(in: &subs)


        
        
        
        dispatchGroup.enter()
        repository.syncMessages(timestamp: repository.getMessagesSyncTimestamp()).sink { [weak self] c in
            print("messages C: ", c)
            self?.dispatchGroup.leave()
        } receiveValue: { [weak self] response in
            print("sync messages: ", response)
            guard let self = self else { return }
            guard let messages = response.data?.messages else { return }
            self.repository.setMessagesSyncTimestamp(Date().currentTimeMillis())
            print("messages before: ", messages.count)
            messages.forEach { message in
                if let roomId = message.roomId {
                    self.repository.saveMessage(message: message, roomId: roomId).sink { c in
                        print("sync messages saving c: ", c)
                    } receiveValue: { message in
                        print("PAPA")
                    }.store(in: &self.subs)
                }
            }
        }.store(in: &subs)
        
        dispatchGroup.enter()
        repository.syncMessageRecords(timestamp: repository.getMessageRecordsSyncTimestamp()).sink { [weak self] c in
            print("sync message records C: ", c)
            self?.dispatchGroup.leave()
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            guard let records = response.data?.messageRecords else { return }
            self.repository.setMessageRecordsSyncTimestamp(Date().currentTimeMillis())
            print("records before: ", records.count)
            
            records.forEach { record in
                self.repository.saveMessageRecord(messageRecord: record).sink { c in
                } receiveValue: { record in
                    print("sync saved message record: ", record)
                    
                }.store(in: &self.subs)
            }
        }.store(in: &subs)
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            print("ALL FINISHEED")
            self?.startSSEConnection()
        }
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
            
            let retryTime = self?.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
//                self?.eventSource?.connect()
            }
        }
        
        eventSource?.onMessage { [weak self] id, event, data in
            print("DATA: ", data)
        
            guard let self = self,
                  let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData)
            else {
                print("SSE decoding error")
                return
            }
            switch sseNewMessage.type {
            case "NEW_MESSAGE":
                guard let message = sseNewMessage.message,
                      let roomId  = message.roomId
                else { return }
                self.currentMessage = message
                self.checkLocalRoom(roomId: roomId)
            case "NEW_MESSAGE_RECORD":
                guard let record = sseNewMessage.messageRecord else { return }
                print("MESSAGE RECORD ON SSE: ", record)
                self.repository.saveMessageRecord(messageRecord: record).sink { c in
                    
                } receiveValue: { record in
                    
                }.store(in: &self.subs)

                break
            default:
                break
            }
        }
        
        eventSource?.addEventListener("message") { id, event, data in
            print("event listener")
        }
    }
    
    func showNotification(imageUrl: URL?, name: String, text: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
            else { return }
            
            self.alertWindow = nil
            let alertWindow = UIWindow(windowScene: windowScene)
            alertWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
            alertWindow.rootViewController = UIViewController()
            alertWindow.isHidden = false
            alertWindow.overrideUserInterfaceStyle = .light // TODO: check colors, theme
            
            let messageNotificationView = MessageNotificationView(imageUrl: imageUrl, senderName: name, textOrDescription: text)
            
            alertWindow.rootViewController?.view.addSubview(messageNotificationView)
            messageNotificationView.anchor(top: alertWindow.rootViewController?.view.safeAreaLayoutGuide.topAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
            messageNotificationView.centerXToSuperview()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
            messageNotificationView.addGestureRecognizer(tapGesture)
            
            self.alertWindow = alertWindow
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.alertWindow = nil
            }
        }
        
    }
    
    @objc func handleGesture(_ sender: UITapGestureRecognizer) {
        // TODO: handle tap
        
        (self.coordinator as? AppCoordinator)?.presentCurrentPrivateChatScreen(room: senderRoom!)
    
        alertWindow = nil
    }
}

extension SSE {
    
    func sendDeliveredStatus(messageIds: [Int64]) {
        repository.sendDeliveredStatus(messageIds: messageIds).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let self = self,
                  let currentMessage = self.currentMessage,
                  let senderRoom = self.senderRoom,
                  let senderRoomUser = senderRoom.users?.first(where: { roomUser in
                roomUser.user?.id == currentMessage.fromUserId
            }),
                  let sender = senderRoomUser.user
            else { return }
            
            self.showNotification(imageUrl: URL(string: sender.getAvatarUrl() ?? "noUrl"),
                                  name: sender.getDisplayName(),
                                  text: currentMessage.body?.text ?? "no text sse")
        }.store(in: &subs)
    }
    
    func checkLocalRoom(roomId: Int64) {
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
            self?.senderRoom = room
            self?.saveMessage(message: currentMessage, room: room)
        }.store(in: &subs)
    }
    
    
    func checkOnlineRoom(roomId: Int64) {
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
                break
            }
        } receiveValue: { message in
            guard let id = message.id else { return }
            self.sendDeliveredStatus(messageIds: [id])
            

        }.store(in: &subs)

    }
    
    
}
