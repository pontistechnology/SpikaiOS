//
//  MessageStateView.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class MessageStateView: UIImageView, BaseView {
    
    let state: MessageState
    
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
        switch state {
        case .sent:
            image = UIImage(named: "sent")
        case .delivered:
            image = UIImage(named: "delivered")
        case .seen:
            image = UIImage(named: "seen")
        case .fail:
            image = UIImage(named: "fail")
        case .waiting:
            image = UIImage(named: "waiting")
        }
    }
    
    func positionSubviews() {
        constrainWidth(16)
        constrainHeight(16)
    }
}
