//
//  ExpandableTextView.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.11.2022..
//  This view will have dynamic height and maximum width.

import UIKit
import Combine

class ExpandableTextView: UITextView, BaseView {
    
    private let placeholderLabel = CustomLabel(text: "message...", textSize: 14, textColor: .textSecondary, fontName: .MontserratMedium)
    private var messageTextViewHeightConstraint = NSLayoutConstraint()
    private var wasMessageTextViewEmpty = true
    
    let textViewIsEmptyPublisher = PassthroughSubject<Bool, Never>()
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupView()
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExpandableTextView {
    
    func addSubviews() {
        addSubview(placeholderLabel)
    }
    
    func styleSubviews() {
        textContainerInset.left = 6
        textContainerInset.right = 36
        layer.cornerRadius = 10
        clipsToBounds = true
        customFont(name: .MontserratMedium)
        backgroundColor = .thirdAdditionalColor
        textColor = .textPrimary
    }
  
    func positionSubviews() {
        placeholderLabel.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        placeholderLabel.centerYToSuperview()
        
        messageTextViewHeightConstraint = heightAnchor.constraint(equalToConstant: 32)
        messageTextViewHeightConstraint.isActive = true
    }
}

extension ExpandableTextView {
    func setText(_ value: String) {
        text = value
        textViewDidChange(self)
    }
    
    func clearTextField(closeKeyboard: Bool = false) {
        text = ""
        textViewDidChange(self)
        if closeKeyboard {
            resignFirstResponder()
        }
    }
}

extension ExpandableTextView: UITextViewDelegate {
        
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count == 0 {
            textViewIsEmptyPublisher.send(true)
            wasMessageTextViewEmpty = true
            placeholderLabel.unhide()
        } else if wasMessageTextViewEmpty {
            textViewIsEmptyPublisher.send(false)
            wasMessageTextViewEmpty = false
            placeholderLabel.hide()
        }
        
        var heightOfTextView: CGFloat = 32
        let numberOfLines = textView.numberOfLines()
        
        switch numberOfLines {
        case 0:
            heightOfTextView = 32
        case 1...5:
            heightOfTextView = 32 + (textView.font?.lineHeight ?? 0) * CGFloat(numberOfLines - 1)
        default:
            heightOfTextView = 32 + 5 * (textView.font?.lineHeight ?? 0)
        }
        
        messageTextViewHeightConstraint.constant = heightOfTextView
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.superview?.layoutIfNeeded()
            }
        }
    }
}
