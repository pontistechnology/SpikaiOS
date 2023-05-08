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
        self.title = .getStringFor(.appereance)
        
        mainView.changeCurrentLabel(to: viewModel.repository.getCurrentAppereance())
    }
}

private extension AppereanceSettingsViewController {
    func setupBindings() {
        mainView.systemModeSwitch.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .unspecified)
            self?.mainView.changeCurrentLabel(to: 0)
        }.store(in: &subscriptions)

        mainView.lightModeSwitch.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .light)
            self?.mainView.changeCurrentLabel(to: 1)
        }.store(in: &subscriptions)

        mainView.darkModeSwitch.tap().sink { [weak self] _ in
            self?.viewModel.changeAppereanceMode(to: .dark)
            self?.mainView.changeCurrentLabel(to: 2)
        }.store(in: &subscriptions)
    }
}
