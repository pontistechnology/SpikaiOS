//
//  TextField.swift
//  Spika
//
//  Created by Marko on 25.10.2021..
//

import UIKit

class TextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    private let textPlaceholder: String
    
    init(textPlaceholder: String = "") {
        self.textPlaceholder = textPlaceholder
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: Constants.Colors.appMediumGray)?.cgColor
        layer.cornerRadius = 10
        
        textColor = UIColor(named: Constants.Colors.textPrimary)
        font = UIFont(name: "Montserrat-Medium", size: 14)
        attributedPlaceholder = NSAttributedString(string: textPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Colors.textTertiary)!])
    }
    
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
