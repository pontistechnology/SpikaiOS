//
//  MessageReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.01.2023..
//

import Foundation
import UIKit

class MessageReactionsView: UIView {
    private var emojiLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary, fontName: .RobotoFlexMedium)
    private var countLabel = CustomLabel(text: "", textSize: 8, textColor: .textPrimary, fontName: .RobotoFlexMedium)
    private let isInMyMessage: Bool
    
    init(emojis: [String], isInMyMessage: Bool) {
        self.isInMyMessage = isInMyMessage
        super.init(frame: .zero)
        setupView()
        show(emojis: emojis)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageReactionsView: BaseView {
    func addSubviews() {
        addSubview(emojiLabel)
        addSubview(countLabel)
    }
    
    func styleSubviews() {
        backgroundColor = .additionalColor
        layer.cornerRadius = 8
        layer.maskedCorners = isInMyMessage ? .allButBottomRight : .allButBottomLeft
    }
    
    func positionSubviews() {
        emojiLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0))
        countLabel.anchor(leading: emojiLabel.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 6))
        countLabel.centerYToSuperview()
    }
}

extension MessageReactionsView {
    func show(emojis: [String]) {
        let maxNumberOfEmojis = 3
        guard let uniqueArray = Array(NSOrderedSet(array: emojis)) as? [String] else { return }
        emojiLabel.text = ""
        _ = uniqueArray.prefix(maxNumberOfEmojis).map { emojiLabel.text?.append($0)}
        
        if emojis.count > maxNumberOfEmojis
            || (uniqueArray.count < emojis.count && emojis.count > 1) {
            countLabel.text = "\(emojis.count)"
        }
    }
}
