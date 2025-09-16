//
//  RoundedLabel.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.07.2023..
//

import Foundation
import UIKit

class RoundedLabel: UILabel {
    let cornerRadius: Double
    init(_ text: String, cornerRadius: Double) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        backgroundColor = .primaryColor
        textAlignment = .center
        textColor = .textPrimary
        self.text = text
    }
    
    override var intrinsicContentSize: CGSize {
        let original = super.intrinsicContentSize
        return .init(width: original.width + 2 * cornerRadius, height: original.height + 2 * cornerRadius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
