//
//  WindowManager.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import Foundation
import UIKit
import Combine

// TODO: check Main thread
final class WindowManager {

    static let shared = WindowManager()
    
    private var subs = Set<AnyCancellable>()
    private var indicatorWindow: UIWindow?
    private var notificationWindow: UIWindow?
    let notificationPublisher = PassthroughSubject<NotificationType, Never>()
    let indicatorColorPublisher  = PassthroughSubject<UIColor, Never>()
    
    private init() {
        setupIndicatorWindow()
        setupBindings()
    }
    
    func foo() {
        print("SSS")
    }
}

// MARK: - Indicator Window
private extension WindowManager {
    func setupIndicatorWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        indicatorWindow = UIWindow(windowScene: windowScene)
        let x = windowScene.screen.bounds.width - 15
        indicatorWindow?.frame = CGRect(x: x, y: 60, width: 8, height: 8)
//        indicatorWindow?.backgroundColor = .appRed
//        indicatorWindow?.rootViewController = ConnectionIndicatorViewController()
        indicatorWindow?.isHidden = false
        indicatorWindow?.clipsToBounds = true
        indicatorWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

// MARK: - Notification window

private extension WindowManager {
    func setupNotificationWindow(info: MessageNotificationInfo) {
        notificationWindow = nil
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        notificationWindow = UIWindow(windowScene: windowScene)
        let padding = 15.0
        notificationWindow?.frame = CGRect(x: padding,
                                           y: 60,
                                           width: windowScene.screen.bounds.width - padding * 2,
                                           height: 150)
        notificationWindow?.clipsToBounds = true
        notificationWindow?.rootViewController = NotificationAlertViewController(info: info)
        notificationWindow?.backgroundColor = .blue
        notificationWindow?.isHidden = false
        notificationWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

extension WindowManager {
    func setupBindings() {
        notificationPublisher.sink { [weak self] type in
            switch type {
            case .show(info: let info):
                self?.setupNotificationWindow(info: info)
            case .tap(info: _):
                self?.notificationWindow = nil
            }
        }.store(in: &subs)
        
        indicatorColorPublisher.sink { [weak self] colora in
            self?.indicatorWindow?.backgroundColor = colora
            self?.indicatorWindow?.layer.cornerRadius = 4
            
//            (self?.indicatorWindow?.rootViewController as? ConnectionIndicatorViewController)?.changeColor(to: colora)
        }.store(in: &subs)
    }
}

// Remember
//windowWorkItem?.cancel()

//if vc is CurrentChatViewController {
//    return
//}
