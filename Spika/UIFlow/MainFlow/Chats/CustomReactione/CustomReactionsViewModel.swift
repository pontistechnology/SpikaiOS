//
//  CustomReactionsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation

class CustomReactionsViewModel: BaseViewModel {
    var allEmojis: [[Emoji]] = []
    
    func getEmojis() {
        allEmojis = repository.getEmojis()
    }
    
    func addToRecentEmojis(emoji: Emoji) {
        repository.addToRecentEmojis(emoji: emoji)
    }
}
