//
//  PrivacySettings.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import UIKit

class PrivacySettingsViewController: BaseViewController {
    
    private let settingsView = PrivacySettingsView(frame: .zero)
    var viewModel: PrivacySettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colors: UIColor._backgroundGradientColors)
        setupView(settingsView)
        setupBinding()
        self.title = .getStringFor(.privacy)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.textPrimary]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func setupBinding() {
        settingsView.blockedUsersButton.tap()
            .sink { [weak self] _ in
//                self?.viewModel.getAppCoordinator()?.presentBlockedUsersSettingsScreen()
                self?.viewModel.showError("Feature coming soon...")
            }.store(in: &self.subscriptions)
        
        settingsView.termsAndConditionsButton.tap().sink { [weak self] _ in
            self?.viewModel.openTermsAndConditions()
        }.store(in: &subscriptions)
    }
    
}
