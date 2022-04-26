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
    var currentMessage: Message?
    var subs = Set<AnyCancellable>()
    
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
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken),
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
        
        eventSource?.onMessage { id, event, data in
            print("SSE on message")
//            print("onMessage: ", id, event, data)
            guard let jsonData = data?.data(using: .utf8) else {
                print("SSE jsonData error")
                return }
            
            do {
                let sseNewMessage = try JSONDecoder().decode(SSENewMessage.self, from: jsonData)
                guard let message = sseNewMessage.message else { return }
                self.repository.saveMessage(message: message).sink { c in
//                    print("completion save message sse: ", c)
                } receiveValue: { (message, localId) in
                    self.currentMessage = message
                    self.showNotification()
                }.store(in: &self.subs)

               
            } catch {
                print("onMessage decoder error catched")
                return
            }
        }
        
        eventSource?.addEventListener("message") { id, event, data in
            print("event listener")
        }
    }
    
    func showNotification() {
        // TODO: First check user in db, then set his name and image. if there is not user, for now say Unknown, but later check online whos that
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene,
                  let currentMessage = self.currentMessage
            else { return }
            // TODO: refactor
            self.alertWindow = nil
            let alertWindow = UIWindow(windowScene: windowScene)
            alertWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
            alertWindow.rootViewController = UIViewController()
            alertWindow.isHidden = false
            alertWindow.overrideUserInterfaceStyle = .light // TODO: check colors, theme
            
            let mess = MessageNotificationView(image: UIImage(named: "matejVida")!, senderName: "Sender id: \(currentMessage.fromUserId)", textOrDescription: currentMessage.body?.text ?? "NOTEXTSSE")
            alertWindow.rootViewController?.view.addSubview(mess)
            mess.anchor(top: alertWindow.rootViewController?.view.safeAreaLayoutGuide.topAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
            mess.centerXToSuperview()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
            mess.addGestureRecognizer(tapGesture)
            
            self.alertWindow = alertWindow
        }
    }
    
    @objc func handleGesture(_ sender: UITapGestureRecognizer) {
        guard let senderId = currentMessage?.fromUserId else {
            return
        }
        
        repository.getUser(withId: senderId).sink { c in
            print(c)
        } receiveValue: { [weak self] user in
            DispatchQueue.main.async {
                (self?.coordinator as? AppCoordinator)?.presentCurrentPrivateChatScreen(user: user)                
            }
        }.store(in: &subs)
        
        alertWindow = nil
        
    }
}
