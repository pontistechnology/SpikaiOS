//
//  MessageReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.01.2023..
//

import Foundation
import UIKit

class MessageReactionsView: UIView {
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageReactionsView: BaseView {
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        backgroundColor = .blue
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    func positionSubviews() {
        
    }
    
    
}
