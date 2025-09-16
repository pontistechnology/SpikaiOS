//
//  OneNoteView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import UIKit

class OneNoteView: UIView {
    
    let titleTextView = UITextViewWithPlaceholder(placeholder: "Enter title", font: .customFont(name: .RobotoFlexSemiBold, size: 16))
    let contentTextView = UITextViewWithPlaceholder(placeholder: "Enter description", font: .customFont(name: .RobotoFlexMedium, size: 12))
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
    
    func configureView(note: Note?) {
        titleTextView.setText(note?.title)
        contentTextView.setText(note?.content)
    }
    
    func changeMode(isEditing: Bool) {
        titleTextView.isEditable = isEditing
        contentTextView.isEditable = isEditing
        if isEditing {
            contentTextView.becomeFirstResponder()
        }
    }
}
