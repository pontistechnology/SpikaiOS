//
//  CustomStackView.swift
//  Spika
//
//  Created by Vedran Vugrin on 17.11.2022..
//

import UIKit

final class CustomStackView: UIStackView {
    
    init(axis: NSLayoutConstraint.Axis = .vertical,
         distribution: UIStackView.Distribution = .fill,
         alignment: UIStackView.Alignment = .fill,
         spacing: CGFloat = 10) {
        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
