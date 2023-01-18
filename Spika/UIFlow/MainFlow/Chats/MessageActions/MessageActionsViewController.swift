//
//  MessageActionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation
import Combine
import UIKit

class MessageActionsViewController: BaseViewController {
    private let mainView = MessageActionsView()
    let tapPublisher = PassthroughSubject<MessageAction, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
    }
}
