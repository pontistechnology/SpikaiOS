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
    
    func startSSEConnection(){
        setupSSE()
        eventSource?.connect()
    }
    
    func setupSSE() {
        guard let accessToken = userDefaults.string(forKey: Constants.UserDefaults.accessToken),
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
            guard let self = self else { return }
            
            
            guard let jsonData = data?.data(using: .utf8),
                  let sseNewMessage = try? JSONDecoder().decode(SSENewMessage.self, from: jsonData),
                  let message = sseNewMessage.message
            else {
                print("SSE decoding error")
                return
            }
            guard let roomId = message.roomId else { return }
            self.currentMessage = message
            self.checkLocalRoom(roomId: roomId)
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
            self?.senderRoom = room
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
                break
            }
        } receiveValue: { message in
            guard let senderRoomUser = room.users?.first(where: { roomUser in
                roomUser.user?.id == message.fromUserId
            }),
                  let sender = senderRoomUser.user
            else { return }
            
            self.showNotification(imageUrl: URL(string: sender.getAvatarUrl() ?? "noUrl"),
                                  name: sender.getDisplayName(),
                                  text: message.body?.text ?? "no text sse")
        }.store(in: &subs)

    }
    
    
}
