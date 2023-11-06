//
//  SettingsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class SettingsView: BaseSettingsView {
    
    let userInfoStackView = CustomStackView(axis: .vertical, distribution: .equalSpacing, alignment: .center, spacing: 15)
    
    let userImage = ImageViewWithIcon(image:  UIImage(safeImage: .userImage),size: CGSize(width: 120, height: 120))
    
    let userName = CustomButton(text: "", textSize: 18, textColor: .textPrimary, fontName: .MontserratSemiBold)
    let userNameTextField = TextField()
    
    let userPhoneNumber = CustomLabel(text: .getStringFor(.group), textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    
    let appereanceOptionButton = NavView(text: .getStringFor(.appereance))
    let privacyOptionButton = NavView(text: .getStringFor(.privacy))
    
    let deleteMyAccountButton = NavView(text: .getStringFor(.deleteMyAccount), isArrowHidden: true)
    
    let appVersion = CustomLabel(text: "", textSize: 16, textColor: .textSecondary, fontName: .MontserratLight, alignment: .center)
//    let accessToken = UITextField() // delete later
    
    let userNameChanged = PassthroughSubject<String,Never>()
    
    override func styleSubviews() {
        super.styleSubviews()
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.autocorrectionType = .no
        userNameTextField.autocapitalizationType = .none
        userNameTextField.returnKeyType = .done
        userNameTextField.delegate = self
        userNameTextField.hide()
        
        deleteMyAccountButton.label.textColor = ._warningColor
    }
    
    override func addSubviews() {
        super.addSubviews()
        mainStackView.addArrangedSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(userImage)
        userInfoStackView.addArrangedSubview(userName)
        userInfoStackView.addArrangedSubview(userPhoneNumber)
        
        mainStackView.addArrangedSubview(appereanceOptionButton)
        mainStackView.addArrangedSubview(privacyOptionButton)
        mainStackView.addArrangedSubview(deleteMyAccountButton)
        
        mainStackView.addArrangedSubview(appVersion)
//        mainStackView.addArrangedSubview(accessToken)
        
        self.contentView.addSubview(self.userNameTextField)
    }
    
    override  func positionSubviews() {
        super.positionSubviews()
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

extension SettingsView: UITextFieldDelegate {
    
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
