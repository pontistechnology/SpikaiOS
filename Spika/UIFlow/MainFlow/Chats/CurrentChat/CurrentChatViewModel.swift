//
//  CurrentChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation

class CurrentChatViewModel: BaseViewModel {
        
    var testMessages: [MessageTest] = [
        MessageTest(messageType: .text, textOfMessage: "prva", replyMessageId: nil, senderName: "anto"),
        MessageTest(messageType: .voice, textOfMessage: "druga", replyMessageId: 0, senderName: "anto"),
        MessageTest(messageType: .voice, textOfMessage: "treca", replyMessageId: nil, senderName: "anto"),
        MessageTest(messageType: .text, textOfMessage: "cetvrta", replyMessageId: 2, senderName: "anto")
    ]
    
}
