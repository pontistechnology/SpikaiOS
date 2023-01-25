//
//  BlockedUsersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation

final class BlockedUsersView: BaseSettingsView {
    
    let chatMembersView = ChatMembersView(contactsEditable: true)
    
    override func styleSubviews() {
        super.styleSubviews()
        chatMembersView.isAdmin.send(true)
    }
    
    override func addSubviews() {
        super.addSubviews()
        self.mainStackView.addArrangedSubview(chatMembersView)
    }
    
}
