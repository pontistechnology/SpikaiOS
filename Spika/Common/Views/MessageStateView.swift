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
            image = UIImage(safeImage: .sent)
        case .delivered:
            image = UIImage(safeImage: .delivered)
        case .seen:
            image = UIImage(safeImage: .seen)
        case .fail:
            image = UIImage(safeImage: .fail)
        case .waiting:
            image = UIImage(safeImage: .waiting)
        }
    }
}
