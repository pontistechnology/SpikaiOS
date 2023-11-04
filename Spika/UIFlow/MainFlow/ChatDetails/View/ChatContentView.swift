//
//  ChatContentView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit
import Combine

class ChatContentView: UIView, BaseView {
    
    let chatImage = ImageViewWithIcon(image:  UIImage(safeImage: .userImage),size: CGSize(width: 120, height: 120))
    
    let chatName = CustomLabel(text: .getStringFor(.group), textColor: .textPrimary, fontName: .MontserratSemiBold)
    let phoneNumberLabel = CustomLabel(text: .getStringFor(.phoneNumber), textColor: .textPrimary, fontName: .MontserratSemiBold)
    let chatNameTextField = TextField()
    
    let sharedMediaOptionButton = NavView(text: .getStringFor(.sharedMediaLinksDocs))
    let chatSearchOptionButton = NavView(text: .getStringFor(.chatSearch))
    let callHistoryOptionButton = NavView(text: .getStringFor(.callHistory))
    
    let notesOptionButton = NavView(text: .getStringFor(.notes))
    let favoriteMessagesOptionButton = NavView(text: .getStringFor(.favorites))
    
    let pinChatSwitchView = SwitchView(text: .getStringFor(.pinchat))
    let muteSwitchView = SwitchView(text: .getStringFor(.mute))
    
    let chatMembersView = ChatMembersView(canAddNewMore: true)
    
    let blockButton = CustomButton(text: .getStringFor(.block), textSize: 14, textColor: ._warningColor, alignment: .left)
    let deleteButton = CustomButton(text: .getStringFor(.delete), textSize: 14, textColor: ._warningColor, alignment: .left)
    let leaveButton = CustomButton(text: .getStringFor(.exitGroup), textSize: 14, textColor: ._warningColor, alignment: .left)
    
    let chatNameChanged = PassthroughSubject<String,Never>()
    
    lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    } ()
    
    lazy var labelStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        positionSubviews()
        styleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubviews() {
        self.addSubview(chatImage)
        self.addSubview(chatName)
        self.addSubview(phoneNumberLabel)
        self.addSubview(mainStackView)
        self.addSubview(chatNameTextField)
        
        mainStackView.addArrangedSubview(sharedMediaOptionButton)
        mainStackView.addArrangedSubview(chatSearchOptionButton)
        mainStackView.addArrangedSubview(callHistoryOptionButton)
        
        mainStackView.addArrangedSubview(notesOptionButton)
        mainStackView.addArrangedSubview(favoriteMessagesOptionButton)
        
        mainStackView.addArrangedSubview(pinChatSwitchView)
        mainStackView.addArrangedSubview(muteSwitchView)
        
        mainStackView.addArrangedSubview(chatMembersView)
        
        mainStackView.addArrangedSubview(self.labelStackView)
        labelStackView.addArrangedSubview(blockButton)
        labelStackView.addArrangedSubview(deleteButton)
        labelStackView.addArrangedSubview(leaveButton)
    }
    
    func styleSubviews() {
        self.blockButton.hide()
        
        chatNameTextField.translatesAutoresizingMaskIntoConstraints = false
        chatNameTextField.autocorrectionType = .no
        chatNameTextField.autocapitalizationType = .none
        chatNameTextField.returnKeyType = .done
        chatNameTextField.delegate = self
        chatNameTextField.hide()
    }
    
    func positionSubviews() {
        chatImage.anchor(top: self.topAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), size: CGSize(width: 120, height: 120))
        chatImage.centerXToSuperview()
        
        chatImage.constrainWidth(120)
        chatImage.constrainHeight(120)
        
        chatName.anchor(top: chatImage.bottomAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        chatName.centerXToSuperview()
        
        phoneNumberLabel.anchor(top: chatName.bottomAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        phoneNumberLabel.centerXToSuperview()
        
        mainStackView.anchor(top: phoneNumberLabel.bottomAnchor,
                             leading: self.leadingAnchor,
                             bottom: self.bottomAnchor,
                             trailing: self.trailingAnchor,
                             padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))

        
        blockButton.constrainHeight(58)
        deleteButton.constrainHeight(58)
        
        chatNameTextField.centerYAnchor.constraint(equalTo: chatName.centerYAnchor).isActive = true
        chatNameTextField.constraintLeading(to: self.mainStackView, constant: 22)
        chatNameTextField.constraintTrailing(to: self.mainStackView, constant: -22)
        chatNameTextField.constrainHeight(50)
    }
    
}

extension ChatContentView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
              !text.isEmpty else { return }
        self.chatNameChanged.send(text)
    }
    
}
