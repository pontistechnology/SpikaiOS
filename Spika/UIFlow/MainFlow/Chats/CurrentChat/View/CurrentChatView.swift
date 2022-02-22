//
//  CurrentChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import UIKit

class CurrentChatView: UIView, BaseView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func styleSubviews() {
        titleLabel.text = "Current Chat View"
    }
    
    func positionSubviews() {
        titleLabel.centerInSuperview()
    }

}
