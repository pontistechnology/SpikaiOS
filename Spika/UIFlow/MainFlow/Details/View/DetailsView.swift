//
//  DetailsView.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class DetailsView: UIView, BaseView {
    
    
    let scrollview = UIScrollView()
    
    let contentView = ContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(scrollview)
        scrollview.addSubview(contentView)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        
        scrollview.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        
        contentView.anchor(top: scrollview.topAnchor, leading: scrollview.leadingAnchor, bottom: scrollview.bottomAnchor, trailing: scrollview.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        contentView.constrainHeight(860)
        contentView.widthAnchor.constraint(equalTo: scrollview.widthAnchor).isActive = true
    }
}
