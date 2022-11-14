//
//  ContentView.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class ContentView: UIView, BaseView {
    
    let profilePhoto = UIImageView()
    let nameLabel = CustomLabel(text: "Name and Surname", fontName: .MontserratSemiBold)
    let messageButton = ImageButton(image: UIImage(safeImage: .chatBubble))
    let phoneCallButton = ImageButton(image: UIImage(safeImage: .phoneCall))
    let videoCallButton = ImageButton(image: UIImage(safeImage: .videoCall))
//    let testLabel = CustomLabel(text: "Test")
    let optionButtonsStackView = UIStackView()
    let switchStackView = UIStackView()
    let labelsStackView = UIStackView()
    let sharedMediaOptionButton = NavView(text: "Shared Media, Links and Docs")
    let chatSearchOptionButton = NavView(text: "Chat search")
    let callHistoryOptionButton = NavView(text: "Call history")
    let notesOptionButton = NavView(text: "Notes")
    let favoriteMessagesOptionButton = NavView(text: "Favorite messages")
    let pinChatSwitchView = SwitchView(text: "Pin chat")
    let muteSwitchView = SwitchView(text: "Mute")
    let blockLabel = CustomLabel(text: "Block", textSize: 14, textColor: .appRed)
    let reportLabel = CustomLabel(text: "Report", textSize: 14, textColor: .appRed)
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(nameLabel)
        addSubview(profilePhoto)
        addSubview(messageButton)
        addSubview(phoneCallButton)
        addSubview(videoCallButton)
//        addSubview(testLabel)
        addSubview(optionButtonsStackView)
        optionButtonsStackView.addArrangedSubview(sharedMediaOptionButton)
        optionButtonsStackView.addArrangedSubview(chatSearchOptionButton)
        optionButtonsStackView.addArrangedSubview(callHistoryOptionButton)
        optionButtonsStackView.addArrangedSubview(notesOptionButton)
        optionButtonsStackView.addArrangedSubview(favoriteMessagesOptionButton)
        addSubview(switchStackView)
        switchStackView.addArrangedSubview(pinChatSwitchView)
        switchStackView.addArrangedSubview(muteSwitchView)
        addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(blockLabel)
        labelsStackView.addArrangedSubview(reportLabel)

    }
    
    func styleSubviews() {
        
        profilePhoto.image = UIImage(safeImage: .testImage)
        profilePhoto.layer.cornerRadius = 50
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.clipsToBounds = true
        
        optionButtonsStackView.axis = .vertical
        optionButtonsStackView.distribution = .fill
        
        switchStackView.axis = .vertical
        switchStackView.distribution = .fill
        
        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fillEqually
    }
    
    func positionSubviews() {
        
        profilePhoto.anchor(top: topAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), size: CGSize(width: 100, height: 100))
        profilePhoto.centerXToSuperview()
        
        nameLabel.anchor(top: profilePhoto.bottomAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        nameLabel.centerXToSuperview()
        
        phoneCallButton.anchor(top: nameLabel.bottomAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))
        phoneCallButton.centerXToSuperview()
        
        videoCallButton.anchor(top: phoneCallButton.topAnchor, leading: phoneCallButton.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0))
        
        messageButton.anchor(top: phoneCallButton.topAnchor, trailing: phoneCallButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 24))
        
        optionButtonsStackView.anchor(top: messageButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))
//        optionButtonsStackView.constrainHeight(300)
        
        switchStackView.anchor(top: optionButtonsStackView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
//        switchStackView.constrainHeight(120)
        
        labelsStackView.anchor(top: switchStackView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
//        labelsStackView.constrainHeight(120)
        blockLabel.constrainHeight(80)
        
    }
}
