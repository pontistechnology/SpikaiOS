//
//  FavoritesView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class FavoritesView: UIView, BaseView {
    
    let testLabel = CustomLabel(text: .getStringFor(.favorites), textColor: .checkWithDesign)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(testLabel)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        testLabel.centerInSuperview()
    }
}
