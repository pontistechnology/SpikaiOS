//
//  BlockedUsersViewController.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import UIKit

class BlockedUsersViewController: BaseViewController {
    
    private let settingsView = BlockedUsersView(frame: .zero)
    var viewModel: BlockedUsersViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(settingsView)
        self.title = .getStringFor(.blockedUsers)
        setupBinding()
    }
    
    func setupBinding() {
        self.viewModel.blockedUsers
            .compactMap { users in
                return users?.map { RoomUser(user: $0) }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.settingsView.chatMembersView.updateWithUsers(users: users)
            })
            .store(in: &self.subscriptions)
    }
    
}
