//
//  EmojiCategoriesView.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.08.2023..
//

import Foundation
import UIKit
import Combine

class EmojiCategoriesView: UIStackView {
    let selectedSection = CurrentValueSubject<Int, Never>(0)
    private let emojiSections: [EmojiSection]
    private let topBorderLine = UIView()
    
    private var subs = Set<AnyCancellable>()
    
    init(emojiSections: [EmojiSection]) {
        self.emojiSections = emojiSections
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiCategoriesView: BaseView {
    
    func selectCategory(at index: Int) {
        arrangedSubviews.forEach { $0.tintColor = ._textSecondary }
        guard index < arrangedSubviews.count else { return }
        arrangedSubviews[index].tintColor = .checkWithDesign
    }
    
    func addSubviews() {
        addSubview(topBorderLine)
        for (index, element) in emojiSections.enumerated() {
            let imageView = UIImageView(image: element.icon.withRenderingMode(.alwaysTemplate))
            imageView.tap().sink { [weak self] _ in
                guard let self else { return }
                self.selectedSection.send(index)
            }.store(in: &subs)
            imageView.contentMode = .scaleAspectFit
            addArrangedSubview(imageView)
        }
    }
    
    func styleSubviews() {
        axis = .horizontal
        distribution = .equalSpacing
        topBorderLine.backgroundColor = ._textSecondary
    }
    
    func positionSubviews() {
        topBorderLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        topBorderLine.constrainHeight(0.5)
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}
