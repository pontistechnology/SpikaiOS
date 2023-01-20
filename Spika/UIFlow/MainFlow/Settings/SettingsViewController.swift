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
//        let userPublisher = self.viewModel.getAppCoordinator().fetchMyUserDetails()
        self.viewModel
            .user
            .compactMap { $0?.avatarFileId?.fullFilePathFromId() }
            .sink { c in
                switch c {
                case .finished:
                    break
                case .failure(let error):
                    break
                }
            } receiveValue: { [weak self] url in
                self?.settingsView.contentView.userImage.showImage(url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.subscriptions)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
