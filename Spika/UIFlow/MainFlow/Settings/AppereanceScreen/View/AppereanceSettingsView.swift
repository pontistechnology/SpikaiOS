//
//  AppereanceSettingsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsView: BaseSettingsView {
    
    let darkModeSwitch = CheckmarkView(text: .getStringFor(.dark))
    let lightModeSwitch = CheckmarkView(text: .getStringFor(.light))
    let systemModeSwitch = CheckmarkView(text: .getStringFor(.system))
    
    override func styleSubviews() {
        super.styleSubviews()
    }
    
    override func addSubviews() {
        super.addSubviews()
        self.mainStackView.addArrangedSubview(darkModeSwitch)
        self.mainStackView.addArrangedSubview(lightModeSwitch)
        self.mainStackView.addArrangedSubview(systemModeSwitch)
    }
    
    override func positionSubviews() {
        super.positionSubviews()
        darkModeSwitch.constrainHeight(50)
        lightModeSwitch.constrainHeight(50)
        systemModeSwitch.constrainHeight(50)
    }
    
}

extension AppereanceSettingsView {
    func changeCurrentLabel(to value: Int) {
        darkModeSwitch.updateIsSelected(isSelected: false)
        lightModeSwitch.updateIsSelected(isSelected: false)
        systemModeSwitch.updateIsSelected(isSelected: false)
        
        switch value {
        case 0:
            systemModeSwitch.updateIsSelected(isSelected: true)
        case 1:
            lightModeSwitch.updateIsSelected(isSelected: true)
        case 2:
            darkModeSwitch.updateIsSelected(isSelected: true)
        default:
            systemModeSwitch.updateIsSelected(isSelected: true)
        }
    }
}
