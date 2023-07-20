//
//  ContextMenuActionView.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation
import UIKit

class ContextMenuActionView: UIView {
    private let action: MessageAction
    private let imageView = UIImageView()
    private let label = CustomLabel(text: "", textSize: 16, textColor: .textPrimary, fontName: .MontserratMedium)
    
    init(messageAction: MessageAction) {
        self.action = messageAction
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContextMenuActionView: BaseView {
    func addSubviews() {
        addSubview(imageView)
        addSubview(label)
    }
    
    func styleSubviews() {
        label.text = action.textForLabel
        imageView.image = UIImage(safeImage: action.assetNameForIcon)
    }
    
    func positionSubviews() {
        imageView.constrainHeight(16)
        imageView.constrainWidth(16)
        imageView.centerYToSuperview()
        imageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0))
        
        label.anchor(top: topAnchor, leading: imageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 10))
    }
}
