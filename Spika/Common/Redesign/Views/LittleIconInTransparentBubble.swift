//
//  LittleIconInTransparentBubble.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.09.2024..
//

import UIKit

class LittleIconInTransparentBubble: UIView {
    let iw: UIImageView
    init(resource: ImageResource) {
        iw = UIImageView(image: UIImage(resource: resource).withTintColor(.textPrimary, renderingMode: .alwaysOriginal))
        super.init(frame: .zero)
        self.backgroundColor = .systemPink
        addSubview(iw)
        
        backgroundColor = .additionalColor
        
        let size = 24.0
        iw.fillSuperview(padding: .init(top: 4, left: 4, bottom: 4, right: 4))
        constrainWidth(size)
        constrainHeight(size)
        layer.cornerRadius = size/2
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
