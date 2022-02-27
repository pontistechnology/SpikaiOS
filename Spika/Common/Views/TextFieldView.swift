////
////  TextFieldView.swift
////  Spika
////
////  Created by Marko on 25.10.2021..
////
//
//import UIKit
//
//class TextFieldView: UIView, BaseView {
//    
//    let titleLabel = CustomLabel(text: "", textSize: 12, textColor: .textTertiary, fontName: .MontserratMedium)
//    var textField = TextField()
//    
//    let placeholder: String
//    let title: String
//    
//    init(placeholder: String = "", title: String = "") {
//        self.title = title
//        self.placeholder = placeholder
//        super.init(frame: .zero)
//        setupView()
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func addSubviews() {
//        addSubview(titleLabel)
//        addSubview(textField)
//    }
//    
//    func styleSubviews() {
//        titleLabel.text = title
//        
//        textField.placeholder = placeholder
//    }
//    
//    func positionSubviews() {
//        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
//        titleLabel.constrainHeight(15)
//        
//        textField.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
//        textField.constrainHeight(50)
//        
//        self.constrainHeight(83)
//        
//    }
//}
