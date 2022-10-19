//
//  LogoImageView.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class LogoImageView: UIImageView {
    
    init(textPlaceholder: String = "") {
        super.init(frame: .zero)
        setupImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImage() {
        self.image = UIImage(safeImage: .logo)
    }

}
