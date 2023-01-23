//
//  File.swift
//  Spika
//
//  Created by Vedran Vugrin on 20.01.2023..
//

import UIKit
import Combine

class SettingsContentView: UIView {
    
    let mainStackView = CustomStackView()
    let userInfoStackView = CustomStackView(axis: .vertical, distribution: .equalSpacing, alignment: .center, spacing: 15)
    
    let userImage = ImageViewWithIcon(image:  UIImage(safeImage: .userImage),size: CGSize(width: 120, height: 120))
    
    let userName = ActionButton()
    let userNameTextField = TextField()
    
    let userPhoneNumber = CustomLabel(text: .getStringFor(.group), textSize: 16, textColor: .textTertiary, fontName: .MontserratSemiBold)
    
    let privacyOptionButton = NavView(text: .getStringFor(.privacy))
    
    let userNameChanged = PassthroughSubject<String,Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        positionSubviews()
        styleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension SettingsContentView: BaseView {
    
    func styleSubviews() {
        userName.titleLabel?.font = .customFont(name: .MontserratSemiBold, size: 20)
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.autocorrectionType = .no
        userNameTextField.autocapitalizationType = .none
        userNameTextField.returnKeyType = .done
        userNameTextField.delegate = self
        userNameTextField.isHidden = true
    }
    
    func addSubviews() {
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(userImage)
        userInfoStackView.addArrangedSubview(userName)
        userInfoStackView.addArrangedSubview(userPhoneNumber)
        
        mainStackView.addArrangedSubview(privacyOptionButton)
        
        self.addSubview(self.userNameTextField)
    }
    
    func positionSubviews() {
        mainStackView.constraintLeading()
        mainStackView.constraintTrailing()
        mainStackView.constraintTop(to: nil, constant: 24)
        mainStackView.constraintBottom()
        
        userNameTextField.centerYAnchor.constraint(equalTo: userName.centerYAnchor).isActive = true
        userNameTextField.constraintLeading(to: self.mainStackView, constant: 22)
        userNameTextField.constraintTrailing(to: self.mainStackView, constant: -22)
        userNameTextField.constrainHeight(50)
    }
    
}

extension SettingsContentView: UITextFieldDelegate {
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
              !text.isEmpty else { return }
        self.userNameChanged.send(text)
    }
    
}
