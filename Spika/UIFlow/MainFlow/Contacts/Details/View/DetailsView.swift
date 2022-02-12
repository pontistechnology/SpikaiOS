//
//  DetailsView.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class DetailsView: UIScrollView, BaseView {
    
    let contentView = ContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(contentView)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        
        contentView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        contentView.constrainHeight(860)
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
