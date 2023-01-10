//
//  MessageReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.01.2023..
//

import Foundation
import UIKit

class MessageReactionsView: UIView {
    private var emojiLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary, fontName: .MontserratMedium)
    private var countLabel = CustomLabel(text: "", textSize: 8, textColor: .textPrimary, fontName: .MontserratMedium)
    
    init() {
        super.init(frame: .zero)
        setupView()
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
        backgroundColor = .blue
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    func positionSubviews() {
        emojiLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0))
        countLabel.anchor(leading: emojiLabel.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 6))
        countLabel.centerYToSuperview()
    }
}

extension MessageReactionsView {
    func show(emojis: [String]) {
        var s = ""
        emojis.prefix(3).map { s.append($0)}
        var c = emojis.count
        emojiLabel.text = s
        if c > 3 {
            countLabel.text = "\(c)"
        }
    }
}
