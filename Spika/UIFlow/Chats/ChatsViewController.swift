//
//  ChatsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class ChatsViewController: BaseViewController {
    
    private let chatsView = ChatsView()
    var viewModel: ChatsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(chatsView)
    }
    
}
