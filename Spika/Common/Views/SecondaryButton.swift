//
//  SecondaryButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class SecondaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        setTitleColor(UIColor(named: Constants.Colors.appBlue), for: .normal)
        layer.cornerRadius = 10
        titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        layer.borderColor = UIColor(named: Constants.Colors.appBlue)!.cgColor
        layer.borderWidth = 1
    }
}
