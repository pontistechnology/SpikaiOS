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
        
        let s = viewModel.repository.getSelectedTheme()
        guard let index = SpikaTheme.allCases.firstIndex(where: { s == $0.rawValue
        }) else { return }
        mainView.changeCurrentLabel(to: index)
    }
}

private extension AppereanceSettingsViewController {
    func setupBindings() {
        mainView.mainStackView.arrangedSubviews.enumerated().forEach { index, view in
            view.tap().sink { [weak self] _ in
                guard let self else { return }
                mainView.changeCurrentLabel(to: index)
                viewModel.changeAppereanceMode(to: viewModel.getThemeFor(index: index))
            }.store(in: &subscriptions)
        }
    }
}
