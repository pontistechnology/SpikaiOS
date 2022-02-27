//
//  MessageViewTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit

class MessageViewTest: UIView, BaseView {
    
    private let textView = UITextView()
    
    private var textViewHeightConstraint = NSLayoutConstraint()
    private var heightConstraint = NSLayoutConstraint()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(textView)
    }
    
    func styleSubviews() {
        backgroundColor = .gray
        
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
    }
    
    func positionSubviews() {
        
        textView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 20))
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint = heightAnchor.constraint(equalToConstant: 56)
        textViewHeightConstraint.isActive = true
        heightConstraint.isActive = true
    }
    
    
}

extension MessageViewTest: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let numberOfLines = textView.numberOfLines()
        var heightOfTextView: CGFloat = 32
        switch numberOfLines {
        case 0:
            heightOfTextView = 32
        case 1...5:
            heightOfTextView = 32 + (textView.font?.lineHeight ?? 0) * CGFloat(textView.numberOfLines() - 1)
        default:
            heightOfTextView = 32 + 5 * (textView.font?.lineHeight ?? 0)
        }
        heightConstraint.constant = heightOfTextView + 24
        textViewHeightConstraint.constant = heightOfTextView
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
