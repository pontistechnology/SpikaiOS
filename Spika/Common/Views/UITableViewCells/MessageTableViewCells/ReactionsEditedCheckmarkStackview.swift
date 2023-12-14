//
//  ReactionsEditedCheckmarkStackview.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.12.2023..
//

import Foundation
import UIKit

class ReactionsEditedCheckmarkStackview: UIStackView {
    private let emptyView = UIView()
    let editedLabel = CustomLabel(text: "edited", textSize: 10, textColor: .textSecondary)
    let messageStateView = MessageStateView()
    let reactionsView: MessageReactionsView
    init(emojis: [String], isMyMessage: Bool) {
        self.reactionsView = MessageReactionsView(emojis: emojis, isInMyMessage: isMyMessage)
        super.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .fill
        self.alignment = .bottom
        spacing = 4
        if isMyMessage {
            addArrangedSubview(emptyView)
            addArrangedSubview(reactionsView)
            addArrangedSubview(editedLabel)
            addArrangedSubview(messageStateView)
        } else {
            addArrangedSubview(editedLabel)
            addArrangedSubview(reactionsView)
            addArrangedSubview(emptyView)
        }
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10)
        
        editedLabel.hide()
        reactionsView.hide()
        messageStateView.hide()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
