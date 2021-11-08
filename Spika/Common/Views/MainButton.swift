//
//  MainButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class MainButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        backgroundColor = UIColor(named: Constants.Colors.appBlue)
        layer.cornerRadius = 10
        titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
    }
    
    func setEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
        backgroundColor = enabled ? UIColor(named: Constants.Colors.appBlue) : UIColor(named: Constants.Colors.appBlue)?.withAlphaComponent(0.5)
    }
    
}
