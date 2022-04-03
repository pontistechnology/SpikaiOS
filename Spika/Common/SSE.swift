//
//  SSE.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.04.2022..
//

import Combine
import Foundation
import IKEventSource
import UIKit

class SSE {
    
    var eventSource: EventSource?
    var alertWindow: UIWindow?
    let repository: Repository
    let coordinator: Coordinator
    
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
        let deviceId = UserDefaults.standard.string(forKey: Constants.UserDefaults.deviceId) // TODO: Check is this needed? Can be 0?
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken),
              let deviceId = deviceId,
              deviceId != "-1",
              let serverURL = URL(string: Constants.Networking.baseUrl
                                  + "api/sse/" + deviceId
                                  + "?accesstoken=" + accessToken)
        else { return }
        print("SSE URL : ", serverURL)
        eventSource = EventSource(url: serverURL)
        
        eventSource?.onOpen { [weak self] in
            print("CONNECTED")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            print("DISCONNECTED")
//
//            guard reconnect ?? false else { return }
            
            let retryTime = self?.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        
        eventSource?.onMessage { id, event, data in
            print("onMessage: ", id, event, data)
            
            guard let jsonData = data?.data(using: .utf8) else { return }
            
            do {
                let test = try JSONDecoder().decode(SSENewMessage.self, from: jsonData)
                self.showNotification(image: UIImage(named: "matejVida")!, senderName: "sse event", textOrDescription: test.message?.body.text ?? "nema teksta")
            } catch {
                print("onMessage decoder error catched")
                return
            }
        }
        
        eventSource?.addEventListener("message") { id, event, data in
            print("event listener")
        }
    }
    
    func showNotification(image: UIImage, senderName: String, textOrDescription: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        
        self.alertWindow = nil
        let alertWindow = UIWindow(windowScene: windowScene)
        alertWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
        alertWindow.rootViewController = UIViewController()
        alertWindow.isHidden = false
        alertWindow.overrideUserInterfaceStyle = .light // TODO: check colors, theme
        
        let mess = MessageNotificationView(image: image, senderName: senderName, textOrDescription: textOrDescription)
        alertWindow.rootViewController?.view.addSubview(mess)
        mess.anchor(top: alertWindow.rootViewController?.view.safeAreaLayoutGuide.topAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        mess.centerXToSuperview()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        mess.addGestureRecognizer(tapGesture)
        
        self.alertWindow = alertWindow
    }
    
    @objc
    func handleGesture(_ sender: UITapGestureRecognizer) {
        (coordinator as? AppCoordinator)?.presentFavoritesScreen() // TODO: present currect chat
        alertWindow = nil
    }
}
