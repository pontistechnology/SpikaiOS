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

    private let scene: UIWindowScene
    private var subs = Set<AnyCancellable>()
    
    private var indicatorWindow: UIWindow?
    private var notificationWindow: UIWindow?
    private var errorWindow: UIWindow?
    
    let notificationPublisher = PassthroughSubject<NotificationType, Never>()
    let indicatorColorPublisher  = PassthroughSubject<UIColor, Never>()
    
    init(scene: UIWindowScene) {
        self.scene = scene
        setupIndicatorWindow()
        setupBindings()
    }
}

// MARK: - Indicator Window
private extension WindowManager {
    func setupIndicatorWindow() {
        indicatorWindow = UIWindow(windowScene: scene)
        let width = 8.0
        indicatorWindow?.frame = CGRect(x: scene.screen.bounds.width - width - 10,
                                        y: 60,
                                        width: width,
                                        height: width)
        indicatorWindow?.backgroundColor = .appRed
        indicatorWindow?.isHidden = false
        indicatorWindow?.layer.cornerRadius = width / 2
        indicatorWindow?.clipsToBounds = true
        indicatorWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

// MARK: - Notification window

private extension WindowManager {
    func setupNotificationWindow(info: MessageNotificationInfo) {
        notificationWindow = nil
        notificationWindow = UIWindow(windowScene: scene)
        let padding = 15.0
        notificationWindow?.frame = CGRect(x: padding,
                                           y: 60,
                                           width: scene.screen.bounds.width - padding * 2,
                                           height: 150)
        notificationWindow?.clipsToBounds = true
        notificationWindow?.rootViewController = NotificationAlertViewController(info: info, tapPublisher: notificationPublisher)
        notificationWindow?.backgroundColor = .blue
        notificationWindow?.isHidden = false
        notificationWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

// MARK: - Error window

private extension WindowManager {
    func setupErrorWindow(something: String) {
        errorWindow = nil
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene
        else { return }
        errorWindow = UIWindow(windowScene: windowScene)
        let padding = 15.0
        errorWindow?.frame = CGRect(x: padding,
                                           y: 60,
                                           width: windowScene.screen.bounds.width - padding * 2,
                                           height: 150)
        errorWindow?.clipsToBounds = true
//        errorWindow?.rootViewController = TODO: d o
        errorWindow?.backgroundColor = .red
        errorWindow?.isHidden = false
        errorWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

extension WindowManager {
    func setupBindings() {
        notificationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
            switch type {
            case .show(info: let info):
                self?.setupNotificationWindow(info: info)
            case .tap(info: _):
                self?.notificationWindow = nil
            }
        }.store(in: &subs)
        
        indicatorColorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] color in
                self?.indicatorWindow?.backgroundColor = color
            }.store(in: &subs)
    }
}

extension WindowManager {
    func testn() {
        print("RADI")
    }
}
