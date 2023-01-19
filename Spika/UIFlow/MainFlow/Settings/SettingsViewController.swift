//
//  SettingsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class SettingsViewController: BaseViewController {
    
    private let settingsView = SettingsView()
    var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(settingsView)
        settingsView.titleLabel.text = "Build number: " + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
