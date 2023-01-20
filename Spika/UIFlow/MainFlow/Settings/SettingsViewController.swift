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
        setupBinding()
//        settingsView.titleLabel.text = "Build number: " + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown")
    }
    
    func setupBinding() {
        self.viewModel
            .user
            .compactMap { $0?.avatarFileId?.fullFilePathFromId() }
            .sink { c in
            } receiveValue: { [weak self] url in
                self?.settingsView.contentView.userImage.showImage(url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.subscriptions)
        
        self.viewModel
            .user
            .compactMap { $0?.displayName }
            .sink { c in
            } receiveValue: { [weak self] text in
                self?.settingsView.contentView.userName.setText(text: text)
            }.store(in: &self.subscriptions)
        
        self.viewModel
            .user
            .compactMap { $0?.telephoneNumber }
            .sink { c in
            } receiveValue: { [weak self] text in
                self?.settingsView.contentView.userPhoneNumber.setText(text: text)
            }.store(in: &self.subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
