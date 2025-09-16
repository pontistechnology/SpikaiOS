//
//  OptionButton.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2022..
//

import UIKit

class NavView: UIView, BaseView {
    
    let label = CustomLabel(text: "text", textSize: 14, textColor: .textPrimary, fontName: .RobotoFlexSemiBold)
    let arrowImageView = UIImageView()
    let text: String
    let emptyview = UIView()
    
    init(text: String, isArrowHidden: Bool = false) {
        self.text = text
        super.init(frame: .zero)
        arrowImageView.isHidden = isArrowHidden
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(emptyview)
        emptyview.addSubview(label)
        emptyview.addSubview(arrowImageView)
    }
    
    func styleSubviews() {
        label.text = text
        arrowImageView.image = UIImage(resource: .rDrightArrow).withTintColor(.textPrimary, renderingMode: .alwaysOriginal)
        emptyview.backgroundColor = .primaryColor
        emptyview.layer.cornerRadius = 16
    }
    
    func positionSubviews() {
        emptyview.fillSuperview(padding: .init(top: 2, left: 16, bottom: 2, right: 16))
        label.anchor(leading: emptyview.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        label.centerYToSuperview()
        
        arrowImageView.anchor(trailing: emptyview.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        arrowImageView.centerYToSuperview()
        
        self.constrainHeight(58)
    }
}
