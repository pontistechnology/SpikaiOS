//
//  RoundedImageView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.01.2023..
//

import UIKit

final class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
    
}
