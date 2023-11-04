//
//  AppereanceSettingsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsView: BaseSettingsView {
    
    let apply = CustomLabel(text: "Apply", textColor: .checkWithDesign)
    
    override func styleSubviews() {
        super.styleSubviews()
    }
    
    override func addSubviews() {
        super.addSubviews()
        SpikaTheme.allCases.forEach { theme in
            let view = CheckmarkView(text: theme.title)
            mainStackView.addArrangedSubview(view)
            view.constrainHeight(50)
        }
        mainStackView.addArrangedSubview(apply)
    }
}

extension AppereanceSettingsView {
    func changeCurrentLabel(to value: Int) {
        guard value < mainStackView.arrangedSubviews.count else { return }
        mainStackView.arrangedSubviews.forEach { ($0 as? CheckmarkView)?.updateIsSelected(isSelected: false)
        }
        (mainStackView.arrangedSubviews[value] as? CheckmarkView)?.updateIsSelected(isSelected: true)
    }
}
