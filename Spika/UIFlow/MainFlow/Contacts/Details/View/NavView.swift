//
//  OptionButton.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2022..
//

import UIKit

class NavView: UIView, BaseView {
    
    let label = CustomLabel(text: "text")
    let arrowImageView = UIImageView()
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(label)
        addSubview(arrowImageView)
    }
    
    func styleSubviews() {
        label.text = text
        arrowImageView.image = UIImage(safeImage: .rightArrow)
    }
    
    func positionSubviews() {
        label.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        label.centerYToSuperview()
        
        arrowImageView.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        arrowImageView.centerYToSuperview()
        
        self.constrainHeight(80)
    }
}
