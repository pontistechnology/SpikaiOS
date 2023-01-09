//
//  UIView+NSLayoutConstraint.swift
//  JumpIn
//
//  Created by Roman Kyrylenko on 6/19/18.
//  Copyright © 2018 JumpIn. All rights reserved.
//

import UIKit

public extension UIView {
    
    func constraint(to view: UIView? = nil, with insets: UIEdgeInsets = .zero) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        
        constraintTop(to: view, constant: insets.top)
        constraintBottom(to: view, constant: insets.bottom)
        constraintTrailing(to: view, constant: insets.right)
        constraintLeading(to: view, constant: insets.left)
    }
    
    @discardableResult
    func constraintBottom(to view: UIView? = nil, constant: CGFloat = 0) -> NSLayoutConstraint {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: constant
        )
        view.addConstraint(constraint)
        
        return constraint
    }
    
    func constraintBottomToTopOf(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        bottomAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
    }
    
    func constraintTop(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
    }
    
    func constraintVertical(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        topAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
    }
    
    func constraintHorizontal(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        leftAnchor.constraint(equalTo: view.rightAnchor, constant: constant).isActive = true
    }
    
    func constraintTrailing(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).isActive = true
    }
    
    func constraintLeading(to view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
    }
    
    func equalHeight(to view: UIView? = nil, multiplier: CGFloat = 1) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier).isActive = true
    }
    
    func equalWidth(to view: UIView? = nil, multiplier: CGFloat = 1) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier).isActive = true
    }
    
    func constantHeight(constant: CGFloat = 0) {
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    func constantWidth(constant: CGFloat = 0) {
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    func centerX(_ view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func centerY(_ view: UIView? = nil, constant: CGFloat = 0) {
        guard let view = view ?? superview else {
            fatalError("Undefined view")
        }
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    }
    
    func constraintToGuide(guide: UILayoutGuide, insets: UIEdgeInsets = UIEdgeInsets.zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.left).isActive = true
        self.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: insets.right).isActive = true
        self.topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.top).isActive = true
        self.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: insets.bottom).isActive = true
    }
    
}

public extension UIView {
    
    enum Constraint {
        case top, bottom, trailing, leading, equalHeight, equalWidth
        case constantLeading(CGFloat)
        case constantTop(CGFloat)
        case centerX, centerY
        case height(CGFloat), width(CGFloat)
        case center, equalSize
    }
    
    func bound(to view: UIView? = nil, with constraint: Constraint) {
        switch constraint {
        case .top: constraintTop(to: view)
        case .constantTop(let constant): constraintTop(to: view, constant: constant)
        case .bottom: constraintBottom(to: view)
        case .trailing: constraintTrailing(to: view)
        case .leading: constraintLeading(to: view)
        case .constantLeading(let constant): constraintLeading(to: view, constant: constant)
        case .equalHeight: equalHeight(to: view)
        case .equalWidth: equalWidth(to: view)
        case .height(let constant): constantHeight(constant: constant)
        case .width(let constant): constantWidth(constant: constant)
        case .centerX: centerX()
        case .centerY: centerY()
        case .center:
            centerX(view)
            centerY(view)
        case .equalSize:
            equalHeight(to: view)
            equalWidth(to: view)
        }
    }
    
    func bound(to view: UIView? = nil, with constraints: [Constraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        for constraint in constraints {
            bound(to: view, with: constraint)
        }
    }
}
