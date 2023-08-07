//
//  OneNoteView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import UIKit

class OneNoteView: UIView {
    
    let titleTextView = UITextView()
    let contentTextView = UITextView()
    private var bottomConstraint: NSLayoutConstraint?
    let keyboardAccessoryView = KeyboardObserverAccessoryView()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OneNoteView: BaseView {
    func addSubviews() {
        addSubview(titleTextView)
        addSubview(contentTextView)
    }
    
    func styleSubviews() {
        titleTextView.isScrollEnabled = false
        titleTextView.font = .customFont(name: .MontserratSemiBold, size: 18)
        contentTextView.font = .customFont(name: .MontserratMedium, size: 14)
        contentTextView.keyboardDismissMode = .interactive
        contentTextView.inputAccessoryView = keyboardAccessoryView
        contentTextView.dataDetectorTypes = [.link, .phoneNumber]
    }
    
    func positionSubviews() {
        titleTextView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 24, bottom: 0, right: 24))
        
        titleTextView.textContainer.heightTracksTextView = true
        
        contentTextView.anchor(top: titleTextView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 24, bottom: 0, right: 24))
        bottomConstraint = contentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
    }
    
    func moveInputFromBottom(for n: CGFloat) {
        bottomConstraint?.constant = -(n > 30 ? n - 30 : 0)
        DispatchQueue.main.async { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    func configureView(note: Note) {
        titleTextView.text = note.title
        contentTextView.text = note.content
    }
    
    func changeMode(isEditing: Bool) {
        titleTextView.isEditable = isEditing
        contentTextView.isEditable = isEditing
        if isEditing {
            contentTextView.becomeFirstResponder()
        }
    }
}
