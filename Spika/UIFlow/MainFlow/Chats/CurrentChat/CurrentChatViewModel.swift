//
//  CurrentChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation

class CurrentChatViewModel: BaseViewModel {
        
    var testMessages: [MessageTest] = [
        MessageTest(messageType: .text, textOfMessage: "prva", replyMessageId: nil, senderName: "anto", isMyMessage: false),
        MessageTest(messageType: .text, textOfMessage: "druga koja je malo duza hahfsajk fjksa nkjsanf kjsn jkfnsakj nfkjsan kjdn fkjnaskd njahah hah hah hahah ", replyMessageId: 0, senderName: "anto", isMyMessage: false),
        MessageTest(messageType: .text, textOfMessage: "druga koja je malo duza hahfsajk fjksa nkjsanf kjsn jkfnsakj nfkjsan kjdn fkjnaskd njahah hah hah hahah ", replyMessageId: 0, senderName: "anto", isMyMessage: true),
//        MessageTest(messageType: .voice, textOfMessage: "treca", replyMessageId: nil, senderName: "anto"),
//        MessageTest(messageType: .text, textOfMessage: "cetvrta", replyMessageId: 2, senderName: "anto")
    ]
}
