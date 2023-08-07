//
//  UITextViewWithPlaceholder.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation
import UIKit

class UITextViewWithPlaceholder: UITextView {
    private let placeholderLabel = CustomLabel(text: "")
    
    init(placeholder: String, font: UIFont) {
        super.init(frame: .zero, textContainer: nil)
        addSubview(placeholderLabel)
        placeholderLabel.text = placeholder
        placeholderLabel.font = font
        placeholderLabel.textColor = .textTertiary
        self.font = font
        placeholderLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 6, bottom: 0, right: 0))
        delegate = self
    }
    
    func setText(_ text: String?) {
        self.text = text
        textViewDidChange(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITextViewWithPlaceholder: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.unhide()
        } else {
            placeholderLabel.hide()
        }
    }
}
