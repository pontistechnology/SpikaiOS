//
//  ChatDetailsView.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit

class ChatDetailsView: UIView, BaseView {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    lazy var  mainHolderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    let chatImage = UIImageView()
    let chatName = CustomLabel(text: "Group", fontName: .MontserratSemiBold)
    
    let sharedMediaOptionButton = NavView(text: "Shared Media, Links and Docs")
    let chatSearchOptionButton = NavView(text: "Chat search")
    let callHistoryOptionButton = NavView(text: "Call history")
    
    let notesOptionButton = NavView(text: "Notes")
    let favoriteMessagesOptionButton = NavView(text: "Favorites")
    
    let pinChatSwitchView = SwitchView(text: "Pin chat")
    let muteSwitchView = SwitchView(text: "Mute")
    let blockLabel = CustomLabel(text: "Block", textSize: 14, textColor: .appRed)
    let reportLabel = CustomLabel(text: "Report", textSize: 14, textColor: .appRed)
    
    lazy var optionButtonsStackView: UIStackView = {
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.mainHolderView)
        
        self.mainHolderView.addSubview(chatImage)
        self.mainHolderView.addSubview(chatName)
        self.mainHolderView.addSubview(optionButtonsStackView)
        
        optionButtonsStackView.addArrangedSubview(sharedMediaOptionButton)
        optionButtonsStackView.addArrangedSubview(chatSearchOptionButton)
        optionButtonsStackView.addArrangedSubview(callHistoryOptionButton)
        
        optionButtonsStackView.addArrangedSubview(notesOptionButton)
        optionButtonsStackView.addArrangedSubview(favoriteMessagesOptionButton)
        
        optionButtonsStackView.addArrangedSubview(pinChatSwitchView)
        optionButtonsStackView.addArrangedSubview(muteSwitchView)
        
        optionButtonsStackView.addArrangedSubview(self.labelStackView)
        labelStackView.addArrangedSubview(blockLabel)
        labelStackView.addArrangedSubview(reportLabel)
    }
    
    func styleSubviews() {
        chatImage.image = UIImage(safeImage: .testImage)
        chatImage.layer.cornerRadius = 50
        chatImage.contentMode = .scaleAspectFill
        chatImage.clipsToBounds = true
    }
    
    func positionSubviews() {
        self.scrollView.fillSuperview()
        self.mainHolderView.anchor(top: self.scrollView.contentLayoutGuide.topAnchor,
                                   leading: self.scrollView.contentLayoutGuide.leadingAnchor,
                                   bottom: self.scrollView.contentLayoutGuide.bottomAnchor,
                                   trailing: self.scrollView.contentLayoutGuide.trailingAnchor)
        self.mainHolderView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        chatImage.anchor(top: self.mainHolderView.topAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), size: CGSize(width: 100, height: 100))
        chatImage.centerXToSuperview()
        
        chatName.anchor(top: chatImage.bottomAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        chatName.centerXToSuperview()
        
        optionButtonsStackView.anchor(top: chatName.bottomAnchor, leading: self.mainHolderView.leadingAnchor, bottom: self.mainHolderView.bottomAnchor, trailing: self.mainHolderView.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0))
        
        blockLabel.constrainHeight(80)
    }
    
}
    
