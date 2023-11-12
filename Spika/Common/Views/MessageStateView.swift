//
//  MessageStateView.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class MessageStateView: UIImageView, BaseView {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
    }
    
    func styleSubviews() {
//        changeState(to: .waiting)
    }
    
    func positionSubviews() {
        constrainWidth(12)
        constrainHeight(12)
    }
    
    func changeState(to value: MessageState) {
        switch value {
        case .sent:
            image = UIImage(resource: .sent)
        case .delivered:
            image = UIImage(resource: .delivered)
        case .seen:
            image = UIImage(resource: .seen)
        case .fail:
            image = UIImage(resource: .fail)
        case .waiting:
            image = UIImage(resource: .waiting)
        }
    }
}
