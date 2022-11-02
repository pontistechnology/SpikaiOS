//
//  NotificationAlertView.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit
import Combine

class NotificationAlertView: UIView {
    private let messageNotificationView: MessageNotificationView
    private var subs = Set<AnyCancellable>()
    
    init(info: MessageNotificationInfo) {
        messageNotificationView = MessageNotificationView(info: info)
        super.init(frame: .zero)
        setupView(info: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deiinit")
    }
}

private extension NotificationAlertView {
    func setupView(info: MessageNotificationInfo) {
        addSubview(messageNotificationView)
        messageNotificationView.centerYToSuperview()
        messageNotificationView.centerXToSuperview()

        messageNotificationView.tap().sink { _ in
            WindowManager.shared.notificationPublisher.send(.tap(info: info))
        }.store(in: &subs)
    }
}
