//
//  File.swift
//  Spika
//
//  Created by Vedran Vugrin on 20.01.2023..
//

import UIKit

class SettingsContentView: UIView {
    
    let mainStackView = CustomStackView()
    let userInfoStackView = CustomStackView(axis: .vertical, distribution: .equalSpacing, alignment: .center, spacing: 15)
    
    let userImage = ImageViewWithIcon(image:  UIImage(safeImage: .userImage),size: CGSize(width: 120, height: 120))
    
    let userName = CustomLabel(text: .getStringFor(.group), textSize: 20, textColor: UIColor.primaryColor, fontName: .MontserratSemiBold)
    let userPhoneNumber = CustomLabel(text: .getStringFor(.group), textSize: 16, textColor: .textTertiary, fontName: .MontserratSemiBold)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        positionSubviews()
        styleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension SettingsContentView: BaseView {
    
    func styleSubviews() {}
    
    func addSubviews() {
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(userImage)
        userInfoStackView.addArrangedSubview(userName)
        userInfoStackView.addArrangedSubview(userPhoneNumber)
    }
    
    func positionSubviews() {
        mainStackView.constraintLeading()
        mainStackView.constraintTrailing()
        mainStackView.constraintTop(to: nil, constant: 24)
        mainStackView.constraintBottom()
    }
    
}
