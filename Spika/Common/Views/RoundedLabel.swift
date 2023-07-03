//
//  RoundedLabel.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.07.2023..
//

import Foundation
import UIKit

class RoundedLabel: UILabel {
    init(_ text: String, cornerRadius: Double) {
        super.init(frame: .zero)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        backgroundColor = .textPrimary
        textAlignment = .center
        textColor = .primaryBackground
        self.text = text
    }
    
    override var intrinsicContentSize: CGSize {
        let original = super.intrinsicContentSize
        return .init(width: original.width + 20, height: original.height + 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
