//
//  EnterNumberTextField.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import UIKit

protocol EnterNumberTextFieldDelegate: AnyObject {
    func enterNumberTextField(_ enterNumberTextField: EnterNumberTextField, valueDidChange value: String)
}

class EnterNumberTextField: UIView, BaseView {
    
    let titleLabel = CustomLabel(text: "", textColor: .textPrimary,
                                 fontName: .RobotoFlexMedium)
    private var textField = UITextField()
    let numberView = UIView()
    let countryNumberLabel = CustomLabel(text: "", textColor: .primaryColor, fontName: .RobotoFlexMedium, alignment: .center)
    private let lineBreakView = UIView()
    
    private let placeholder: String
    private let title: String
    private var countryNumber: String
    weak var delegate: EnterNumberTextFieldDelegate?
    
    init(placeholder: String = "",
         title: String = "",
         countryNumber: String = CountryHelper.shared.getCountry(code: Locale.current.regionCode)?.phoneCode ?? "+385") {
        self.title = title
        self.placeholder = placeholder
        self.countryNumber = countryNumber
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(numberView)
        numberView.addSubview(countryNumberLabel)
        numberView.addSubview(lineBreakView)
        numberView.addSubview(textField)
    }
    
    func styleSubviews() {
        
        titleLabel.text = title
            
        countryNumberLabel.text = countryNumber
        
        lineBreakView.backgroundColor = .textSecondary
        
        textField.keyboardType = .phonePad
        textField.placeholder = placeholder
        textField.textColor = .textPrimary
        textField.font = .customFont(name: .RobotoFlexSemiBold, size: 24)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary])
        
        numberView.backgroundColor = .secondaryColor
        numberView.layer.cornerRadius = 30
    }
    
    func positionSubviews() {
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        
        numberView.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        numberView.constrainHeight(50)
        
        countryNumberLabel.anchor(leading: numberView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0))
        countryNumberLabel.constrainWidth(45)
        countryNumberLabel.centerY(inView: numberView)
        
        lineBreakView.anchor(leading: countryNumberLabel.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0), size: CGSize(width: 1, height: 30)) //right
        lineBreakView.centerY(inView: numberView)
        
        textField.anchor(leading: lineBreakView.trailingAnchor, trailing: numberView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0))
        textField.centerY(inView: numberView)
        
        self.constrainHeight(83)
        
    }
    
    private func setupBindings() {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let value = textField.text {
            delegate?.enterNumberTextField(self, valueDidChange: value)
        }
    }
    
    func getNumber() -> String? {
        guard let substring = textField.text?.drop(while: { $0 == "0" }) else { return nil }
        return String(substring)
    }
    
    func setRestOfNumber(_ string: String) {
        textField.text = string
    }
}
