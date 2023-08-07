//
//  OneNoteView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import UIKit

class OneNoteView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OneNoteView: BaseView {
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        
    }
}