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
    var userSender: User?
    
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
        
        eventSource?.onMessage { id, event, data in
            print("SSE on message")
//            print("onMessage: ", id, event, data)
            guard let jsonData = data?.data(using: .utf8) else {
                print("SSE jsonData error")
                return }
            
            do {
                let sseNewMessage = try JSONDecoder().decode(SSENewMessage.self, from: jsonData)
                guard let message = sseNewMessage.message else { return }
                self.currentMessage = nil
                self.userSender = nil
                print("\nSSE message: ", message)
                self.repository.saveMessage(message: message).sink { c in
//                    print("completion save message sse: ", c)
                } receiveValue: { message in
                    self.currentMessage = message
                    self.prepareMessageForShowing()
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
    
    func prepareMessageForShowing() {
        guard let currentMessage = currentMessage,
              let senderId = currentMessage.fromUserId,
              senderId != repository.getMyUserId()
        else {
            return
        }
        repository.getUser(withId: senderId).sink { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                break
            case .failure(_):
                self.showNotification(imageUrl: nil, name: "Unknown", text: currentMessage.body?.text ?? "no sse message")
            }
        } receiveValue: { [weak self] user in
            guard let self = self else { return }
            self.userSender = user
            self.showNotification(imageUrl: URL(string: user.getAvatarUrl() ?? ""),
                                  name: user.getDisplayName(),
                                  text: currentMessage.body?.text ?? "no sse message")
        }.store(in: &subs)
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
        }
    }
    
    @objc func handleGesture(_ sender: UITapGestureRecognizer) {
        // TODO: What if sender is unknown?
        guard let userSender = userSender else {
            return
        }
        DispatchQueue.main.async {
            (self.coordinator as? AppCoordinator)?.presentCurrentPrivateChatScreen(user: userSender)
        }
        alertWindow = nil
    }
}
