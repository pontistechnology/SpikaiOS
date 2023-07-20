//
//  CallHistoryViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class CallHistoryViewController: BaseViewController {
    
    private let callHistoryView = CallHistoryView()
    var viewModel: CallHistoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(callHistoryView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
