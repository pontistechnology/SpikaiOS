//
//  BlockedUsersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation

final class BlockedUsersView: BaseSettingsView {
    
    let chatMembersView = ChatMembersView(canAddNewMore: false)
    
    override func styleSubviews() {
        super.styleSubviews()
        chatMembersView.editable.send(true)
    }
    
    override func addSubviews() {
        super.addSubviews()
        self.mainStackView.addArrangedSubview(chatMembersView)
    }
    
}
