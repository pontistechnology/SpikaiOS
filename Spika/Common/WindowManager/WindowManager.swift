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
    private var popUpWindow: UIWindow?
    
    let notificationTapPublisher = PassthroughSubject<MessageNotificationInfo, Never>()
    let popUpPublisher = PassthroughSubject<PopUpPublisherType, Never>()
    
    init(scene: UIWindowScene) {
        self.scene = scene
        setupIndicatorWindow()
        setupBindings()
    }
}

// MARK: - Indicator Window
extension WindowManager {
    private func setupIndicatorWindow() {
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
    
    func changeIndicatorColor(to color: UIColor) {
        DispatchQueue.main.async { [weak self] in
            self?.indicatorWindow?.backgroundColor = color
        }
    }
}

// MARK: - Notification window

extension WindowManager {
    func showNotificationWindow(info: MessageNotificationInfo) {
        notificationWindow = nil
        notificationWindow = UIWindow(windowScene: scene)
        notificationWindow?.frame = CGRect(x: 0, y: 60,
                                           width: scene.screen.bounds.width, height: 100)
        notificationWindow?.clipsToBounds = true
        notificationWindow?.rootViewController = NotificationAlertViewController(info: info, tapPublisher: notificationTapPublisher)
//        notificationWindow?.backgroundColor = .blue
        notificationWindow?.isHidden = false
        notificationWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

// MARK: - PopUp window

enum PopUpPublisherType {
    case dismiss(after: Int)
    case alertViewTap(Int)
}

extension WindowManager {
    func showPopUp(for type: PopUpType) {
        // Check is error or popup presented 
        popUpWindow = nil
        popUpWindow = UIWindow(windowScene: scene)
        popUpWindow?.frame = type.frame(for: scene)
        popUpWindow?.clipsToBounds = true
        popUpWindow?.rootViewController = PopUpViewController(type, publisher: popUpPublisher)
        popUpWindow?.backgroundColor = type.isBlockingUI ? .gray.withAlphaComponent(0.5) : .clear
        popUpWindow?.isHidden = false
        popUpWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
    }
}

extension WindowManager {
    func setupBindings() {
        notificationTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.notificationWindow = nil
            }.store(in: &subs)
        
        popUpPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type {
                case .dismiss(after: let seconds):
                    self?.dismissPopUpWindowAfter(seconds: seconds)
                case .alertViewTap(_):
                    break
                }
            }.store(in: &subs)
    }
}

extension WindowManager {
    func dismissNotificationWindowAfter(seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.notificationWindow = nil
        }
    }
    
    func dismissPopUpWindowAfter(seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.popUpWindow = nil
        }
    }
}
