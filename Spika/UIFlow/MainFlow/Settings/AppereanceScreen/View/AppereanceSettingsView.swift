//
//  AppereanceSettingsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsView: UIView {
    
    let darkModeLabel = CustomLabel(text: .getStringFor(.darkMode))
    let lightModeLabel = CustomLabel(text: .getStringFor(.lightMode))
    let systemModeLabel = CustomLabel(text: .getStringFor(.systemMode))
    
    private let stackView = CustomStackView(axis: .vertical, distribution: .fillEqually, spacing: 15)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppereanceSettingsView: BaseView {
    func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(darkModeLabel)
        stackView.addArrangedSubview(lightModeLabel)
        stackView.addArrangedSubview(systemModeLabel)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        stackView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
        stackView.constrainHeight(100)
    }
}

extension AppereanceSettingsView {
    
}
