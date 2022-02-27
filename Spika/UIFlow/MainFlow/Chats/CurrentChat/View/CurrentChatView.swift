//
//  CurrentChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import UIKit

class CurrentChatView: UIView, BaseView {
    
    let titleLabel = UILabel()
    let messageSenderView = MessageSenderView()
    let messageTestView = MessageViewTest()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(messageSenderView)
        addSubview(messageTestView)
    }
    
    func styleSubviews() {
        titleLabel.text = "Current Chat View"
    }
    
    func positionSubviews() {
        titleLabel.centerInSuperview()
        
        messageTestView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0))
        
        messageSenderView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        messageSenderView.constrainHeight(60)
        
    }

}
