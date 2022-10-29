//
//  NotificationAlertView.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit
import Combine

class NotificationAlertView: UIView {
    private var messageNotificationView: MessageNotificationView?
    private var subs = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
//        showNotification(info: info)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationAlertView {
    func showNotification(info: MessageNotificationInfo) {
//        addSubview(messageNotificationView)
//        messageNotificationView.centerYToSuperview()
//        messageNotificationView.centerXToSuperview()
//
//        messageNotificationView.tap().sink { _ in
//            WindowManager.shared.notificationTapPublisher.send(info)
//        }.store(in: &subs)
    }
    
    func setupBindings() {
        WindowManager.shared.notificationPublisher.sink { [weak self] info in
            switch info {
            case .show(info: let info):
                self?.showNotification(info: info)
            case .tap(info: _):
                break
            }
        }.store(in: &subs)
    }
}
