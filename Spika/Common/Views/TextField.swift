//
//  TextField.swift
//  Spika
//
//  Created by Marko on 25.10.2021..
//

import UIKit

class CustomTextField: UITextField {
    
    open var inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        backgroundColor = .secondaryColor
        layer.cornerRadius = 10
        
        textColor = .textPrimary
        self.font = .customFont(name: .RobotoFlexMedium, size: 14)
        attributedPlaceholder = NSAttributedString(string: textPlaceholder,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary])
    }
    
    func updateText(text: String?) {
        self.text = text
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }
    
}

