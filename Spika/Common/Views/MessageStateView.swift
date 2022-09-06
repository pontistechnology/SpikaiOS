//
//  MessageStateView.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class MessageStateView: UIImageView, BaseView {
    
    var state: MessageState
    
    init(state: MessageState) {
        self.state = state
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        changeState(to: .waiting)
    }
    
    func positionSubviews() {
        constrainWidth(12)
        constrainHeight(12)
    }
    
    func changeState(to value: MessageState) {
        state = value
        switch state {
        case .sent:
            image = .sent
        case .delivered:
            image = .delivered
        case .seen:
            image = .seen
        case .fail:
            image = .fail
        case .waiting:
            image = .waiting
        }
    }
}
