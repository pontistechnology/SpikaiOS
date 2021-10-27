//
//  ContactsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class ContactsView: UIView, BaseView {
    
    let titleLabel = UILabel()
    let detailsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(detailsButton)
    }
    
    func styleSubviews() {
        titleLabel.text = "Contacts"
        
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.setTitleColor(UIColor.systemTeal, for: .normal)
    }
    
    func positionSubviews() {
        titleLabel.centerInSuperview()
        
        detailsButton.anchor(top: topAnchor, padding: UIEdgeInsets(top: 90, left: 0, bottom: 0, right: 0))
        detailsButton.centerX(inView: self)
    }
    
}
