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
    private let roomIdPublisher = PassthroughSubject<Int64, Never>()
    
    init(scene: UIWindowScene) {
        self.scene = scene
//        setupIndicatorWindow()
        setupBindings()
    }
}

// MARK: - Indicator Window
extension WindowManager {
    private func setupIndicatorWindow() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.indicatorWindow = UIWindow(windowScene: self.scene)
            let width = 8.0
            self.indicatorWindow?.frame = CGRect(x: self.scene.screen.bounds.width - width - 10,
                                            y: 60,
                                            width: width,
                                            height: width)
            self.indicatorWindow?.backgroundColor = .warningColor
            self.indicatorWindow?.unhide()
            self.indicatorWindow?.layer.cornerRadius = width / 2
            self.indicatorWindow?.clipsToBounds = true
            self.indicatorWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
        }
    }
    
    func changeIndicatorColor(to color: UIColor) {
        DispatchQueue.main.async { [weak self] in
            self?.indicatorWindow?.backgroundColor = color
        }
    }
}

// MARK: - Notification window

extension WindowManager {
    func showNotificationWindow(info: MessageNotificationInfo) -> PassthroughSubject<Int64, Never> {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.notificationWindow = nil
            self.notificationWindow = UIWindow(windowScene: self.scene)
            self.notificationWindow?.frame = CGRect(x: 0, y: 60,
                                                    width: self.scene.screen.bounds.width, height: 100)
            self.notificationWindow?.clipsToBounds = true
            self.notificationWindow?.rootViewController = NotificationAlertViewController(info: info, tapPublisher: self.notificationTapPublisher)
            //        self.notificationWindow?.backgroundColor = .blue
            self.notificationWindow?.unhide()
            self.notificationWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
            self.dismissNotificationWindowAfter(seconds: 3)
        }
        return roomIdPublisher
    }
}

// MARK: - PopUp window

enum PopUpPublisherType {
    case dismiss(after: Int)
}

extension WindowManager {
    func showPopUp(for type: PopUpType) {
        // TODO: Check is error or popup presented
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.popUpWindow = nil
            self.popUpWindow = UIWindow(windowScene: self.scene)
            self.popUpWindow?.frame = type.frame(for: self.scene)
            self.popUpWindow?.rootViewController = PopUpViewController(type, publisher: self.popUpPublisher)
            self.popUpWindow?.backgroundColor = type.isBlockingUI ? .gray.withAlphaComponent(0.5) : .clear
            self.popUpWindow?.clipsToBounds = true
            self.popUpWindow?.unhide()
            self.popUpWindow?.overrideUserInterfaceStyle = .light // TODO: - remove later, when dark mode design is ready
        }
    }
}

private extension WindowManager {
    func setupBindings() {
        notificationTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.roomIdPublisher.send(info.roomId)
                self?.notificationWindow = nil
            }.store(in: &subs)
        
        popUpPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type {
                case .dismiss(after: let seconds):
                    self?.dismissPopUpWindowAfter(seconds: seconds)
                }
            }.store(in: &subs)
    }
}

private extension WindowManager {
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

// Light / Dark mode

extension WindowManager {
    func changeAppereance(to mode: UIUserInterfaceStyle) {
        scene.keyWindow?.overrideUserInterfaceStyle = mode
    }
}
