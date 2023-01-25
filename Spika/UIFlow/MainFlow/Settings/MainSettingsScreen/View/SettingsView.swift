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
    
    let userName = ActionButton()
    let userNameTextField = TextField()
    
    let userPhoneNumber = CustomLabel(text: .getStringFor(.group), textSize: 16, textColor: .textTertiary, fontName: .MontserratSemiBold)
    
    let privacyOptionButton = NavView(text: .getStringFor(.privacy))
    
    let userNameChanged = PassthroughSubject<String,Never>()
    
    override func styleSubviews() {
        super.styleSubviews()
        userName.titleLabel?.font = .customFont(name: .MontserratSemiBold, size: 20)
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.autocorrectionType = .no
        userNameTextField.autocapitalizationType = .none
        userNameTextField.returnKeyType = .done
        userNameTextField.delegate = self
        userNameTextField.isHidden = true
    }
    
    override func addSubviews() {
        super.addSubviews()
        mainStackView.addArrangedSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(userImage)
        userInfoStackView.addArrangedSubview(userName)
        userInfoStackView.addArrangedSubview(userPhoneNumber)
        
        mainStackView.addArrangedSubview(privacyOptionButton)
        
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
    
//    lazy var scrollView: UIScrollView = {
//        let view = UIScrollView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    } ()
    
//    let contentView = SettingsContentView(frame: .zero)
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    func addSubviews() {
//        self.addSubview(self.scrollView)
//        self.scrollView.addSubview(self.contentView)
//    }
//
//    func styleSubviews() {}
//
//    func positionSubviews() {
//        self.scrollView.fillSuperview()
//
//        self.contentView.anchor(top: self.scrollView.contentLayoutGuide.topAnchor,
//                                leading: self.scrollView.contentLayoutGuide.leadingAnchor,
//                                bottom: self.scrollView.contentLayoutGuide.bottomAnchor,
//                                trailing: self.scrollView.contentLayoutGuide.trailingAnchor)
//        self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//    }
    
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
