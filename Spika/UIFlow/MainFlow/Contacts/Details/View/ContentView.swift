//
//  ContentView.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class ContentView: UIView, BaseView {
    
    let profilePhoto = UIImageView()
    let nameLabel = CustomLabel(text: .getStringFor(.nameAndSurname), textColor: .textPrimary, fontName: .MontserratSemiBold)
    let phoneNumberLabel = CustomLabel(text: .getStringFor(.phoneNumber), textColor: .textPrimary, fontName: .MontserratSemiBold)
    let messageButton = ImageButton(image: UIImage(resource: .rDchatBubble))
    let phoneCallButton = ImageButton(image: UIImage(resource: .phoneCall))
    let videoCallButton = ImageButton(image: UIImage(resource: .videoCall))
    let optionButtonsStackView = UIStackView()
    let switchStackView = UIStackView()
    let labelsStackView = UIStackView()
    let sharedMediaOptionButton = NavView(text: .getStringFor(.mediaLinksDocs))
    let chatSearchOptionButton = NavView(text: .getStringFor(.chatSearch))
    let callHistoryOptionButton = NavView(text: .getStringFor(.callHistory))
    let notesOptionButton = NavView(text: .getStringFor(.notes))
    let favoriteMessagesOptionButton = NavView(text: .getStringFor(.favoriteMessages))
    let pinChatSwitchView = SwitchView(text: .getStringFor(.pinchat))
    let muteSwitchView = SwitchView(text: .getStringFor(.mute))
    let blockLabel = CustomLabel(text: .getStringFor(.block), textSize: 14, textColor: .warningColor)
    let reportLabel = CustomLabel(text: .getStringFor(.report), textSize: 14, textColor: .warningColor)
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(nameLabel)
        addSubview(phoneNumberLabel)
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
        
        profilePhoto.image = UIImage(resource: .rDdefaultUser)
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
        
        phoneNumberLabel.anchor(top: nameLabel.bottomAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        phoneNumberLabel.centerXToSuperview()
        
        phoneCallButton.anchor(top: phoneNumberLabel.bottomAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))
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
