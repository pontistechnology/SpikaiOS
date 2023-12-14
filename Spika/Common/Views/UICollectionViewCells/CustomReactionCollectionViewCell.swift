//
//  CustomReactionCollectionViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.08.2023..
//

import Foundation
import UIKit

class CustomReactionCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomReactionCollectionViewCell"
    static let widthOrHeight: Double = 32.0
    
    private let emojiLabel = CustomLabel(text: "", textSize: 26, textColor: .checkWithDesign)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomReactionCollectionViewCell: BaseView {
    func addSubviews() {
        contentView.addSubview(emojiLabel)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        emojiLabel.centerInSuperview()
    }
}

extension CustomReactionCollectionViewCell {
    func configureCell(emoji: String) {
        emojiLabel.text = emoji
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
    }
}
