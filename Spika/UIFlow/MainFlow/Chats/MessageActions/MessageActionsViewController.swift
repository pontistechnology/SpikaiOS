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
    private let viewModel: MessageActionsViewModel
    private lazy var mainView = MessageActionsView(reactions: viewModel.reactions, actions: viewModel.actions)
    let tapPublisher = PassthroughSubject<MessageAction, Never>()

    init(viewModel: MessageActionsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
    }
}
