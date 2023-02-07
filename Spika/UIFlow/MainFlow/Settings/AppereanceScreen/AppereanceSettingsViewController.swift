//
//  AppereanceSettingsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsViewController: BaseViewController {
    private let mainView = AppereanceSettingsView()
    var viewModel: AppereanceSettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
        setupBindings()
    }
}

private extension AppereanceSettingsViewController {
    func setupBindings() {
        mainView.darkModeLabel.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .dark)
        }.store(in: &subscriptions)
        
        mainView.lightModeLabel.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .light)
        }.store(in: &subscriptions)
        
        mainView.systemModeLabel.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .unspecified)
        }.store(in: &subscriptions)
    }
}
