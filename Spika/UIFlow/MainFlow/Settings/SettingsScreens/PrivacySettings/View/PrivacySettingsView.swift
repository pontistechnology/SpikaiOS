//
//  PrivacySettingsView.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation

final class PrivacySettingsView: BaseSettingsView {
    
    let blockedUsersButton = NavView(text: .getStringFor(.blockedUsers))
    let termsAndConditionsButton = NavView(text: .getStringFor(.termsAndConditions), isArrowHidden: true)
    
    override func styleSubviews() {
        super.styleSubviews()
    }
    
    override func addSubviews() {
        super.addSubviews()
        mainStackView.addArrangedSubview(blockedUsersButton)
        mainStackView.addArrangedSubview(termsAndConditionsButton)
    }
    
}
