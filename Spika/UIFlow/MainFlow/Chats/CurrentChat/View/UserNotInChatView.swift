//
//  UserNotInChatView.swift
//  Spika
//
//  Created by Vedran Vugrin on 06.02.2023..
//

import UIKit

final class UserNotInChatView: UserBlockedView {
    
    override func styleSubviews() {
        super.styleSubviews()
        self.label.text = .getStringFor(.youAreNoLongerMember)
    }
    
    override func addSubviews() {
        self.addSubview(self.verticalStackView)
        self.verticalStackView.addArrangedSubview(self.label)
    }
    
    override func positionSubviews() {
        super.positionSubviews()
        self.constrainHeight(100)
    }
    
}
