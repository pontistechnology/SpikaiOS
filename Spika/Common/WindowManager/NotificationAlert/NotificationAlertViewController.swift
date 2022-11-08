//
//  NotificationAlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit
import Combine

class NotificationAlertViewController: BaseViewController {
    private let notificationAlertView: NotificationAlertView
    private let tapPublisher: PassthroughSubject<MessageNotificationInfo, Never>
    
    init(info: MessageNotificationInfo, tapPublisher: PassthroughSubject<MessageNotificationInfo, Never>) {
        self.tapPublisher = tapPublisher
        notificationAlertView = NotificationAlertView(info: info)
        super.init(nibName: nil, bundle: nil)
        setupBindings(info: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationAlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension NotificationAlertViewController {
    func setupView() {
        view.addSubview(notificationAlertView)
        notificationAlertView.centerXToSuperview()
        notificationAlertView.centerYToSuperview()
    }
    
    func setupBindings(info: MessageNotificationInfo) {
        notificationAlertView
            .tap()
            .sink { [weak self] _ in
                self?.tapPublisher.send(info)
            }.store(in: &subscriptions)
    }
}
