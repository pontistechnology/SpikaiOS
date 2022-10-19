//
//  OTPCodeTextField.swift
//  Spika
//
//  Created by Vedran Vugrin on 18.10.2022..
//

import UIKit

protocol OTPCodeTextFieldDelegate: AnyObject {
    func textFieldDidChange(_ textField: UITextField, entryGood: Bool)
}

final class OTPCodeTextField: UITextField, UITextFieldDelegate {
    
    let otpLength: Int
    
    weak var otpDelegate: OTPCodeTextFieldDelegate?
    
    init(otpLength: Int) {
        self.otpLength = otpLength
        super.init(frame: CGRectZero)
        self.setup()
        self.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        self.otpLength = 0
        super.init(coder: coder)
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardType = .numberPad
        self.textContentType = .oneTimeCode
        self.backgroundColor = .whiteAndDarkBackground2
        self.textAlignment = .center
        self.autocapitalizationType = .none
        self.layer.borderColor = UIColor.textTertiaryAndDarkBackground2.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        self.font = .customFont(name: .MontserratMedium, size: 26)
        self.textColor = .textPrimary
        self.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 > self.otpLength {
        let text = textField.text ?? ""
        let index = text.index(text.startIndex, offsetBy: 6)
            textField.text = String(text[..<index])
        }
        
        let entryGood = textField.text?.count == self.otpLength
        self.layer.borderColor = entryGood ? UIColor.textTertiaryAndDarkBackground2.cgColor : UIColor.red.cgColor
        
        self.otpDelegate?.textFieldDidChange(textField, entryGood: entryGood)
    }
    
}
