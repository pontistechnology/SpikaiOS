//
//  VerificationTextFieldItem.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

class VerificationTextFieldItem: UIView, BaseView {
    
    let textField = VerificationTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(textField)
    }
    
    func styleSubviews() {
        textField.text = ""
        textField.textColor = .textPrimaryAndWhite
        textField.keyboardType = .numberPad
        backgroundColor = .whiteAndDarkBackground2
        layer.borderColor = UIColor.textTertiaryAndDarkBackground2.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.cornerRadius = 10
    }
    
    func positionSubviews() {
        textField.fillSuperview()
        self.constrainHeight(44)
        self.constrainWidth(44)
    }
    
    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}
