//
//  DetailsView.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class DetailsView: UIView, BaseView {
    
    let closeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Has to be implemented as it is required but will never be used")
    }
    
    func addSubviews() {
        addSubview(closeButton)
    }
    
    func styleSubviews() {
        backgroundColor = .white
        
        closeButton.setTitle("Exit", for: .normal)
        closeButton.setTitleColor(UIColor.blue, for: .normal)
    }
    
    func positionSubviews() {
        closeButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 20))
    }
}
