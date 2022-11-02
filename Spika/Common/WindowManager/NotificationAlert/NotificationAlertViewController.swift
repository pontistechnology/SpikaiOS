//
//  NotificationAlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit

class NotificationAlertViewController: BaseViewController {
    private let notificationAlertView: NotificationAlertView
    
    init(info: MessageNotificationInfo) {
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
            .sink { _ in
//                WindowManager.shared.notificationPublisher.send(.tap(info: info))
            }.store(in: &subscriptions)
    }
}
