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
    }
    
}
