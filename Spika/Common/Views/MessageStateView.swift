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
        constrainWidth(17)
        constrainHeight(13)
    }
    
    func changeState(to value: MessageState) {
        switch value {
        case .sent:
            image = UIImage(resource: .rDtick).withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        case .delivered:
            image = UIImage(resource: .rDtwoTicks)
                .withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        case .seen:
            image = UIImage(resource: .rDtwoTicks)
                .withTintColor(.textTertiary, renderingMode: .alwaysOriginal)
        case .fail:
            image = UIImage(resource: .rDAlertTriangle)
        case .waiting:
            image = UIImage(resource: .rDclock)
                .withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        }
    }
}
