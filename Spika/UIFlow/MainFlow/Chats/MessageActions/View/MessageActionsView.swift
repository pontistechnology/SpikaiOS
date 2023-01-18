//
//  MessageActionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation
import UIKit

class MessageActionsView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageActionsView: BaseView {
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        
    }
}