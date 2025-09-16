////
////  AlertView.swift
////  Spika
////
////  Created by Nikola Barbarić on 04.11.2022..
////
//
//import UIKit
//import Combine
//
//class AlertView: UIView {
//    private let titleLabel: CustomLabel
//    private let messageLabel: CustomLabel
//    private let buttonsStackView = UIStackView()
//    private let dividerLine = UIView(backgroundColor: .gray) // TODO: - check color
//    private var subs = Set<AnyCancellable>()
//    let tapPublisher = PassthroughSubject<Int, Never>()
//    
//    init(title: String, message: String, buttons: [AlertViewButton]) {
//        titleLabel = CustomLabel(text: message, textSize: 14, textColor: ._textPrimary, fontName: .MontserratMedium, alignment: .center)
//        messageLabel = CustomLabel(text: message, textSize: 12, textColor: ._textSecondary, fontName: .MontserratMedium, alignment: .center)
//        super.init(frame: .zero)
//        setupButtonsStackView(buttons)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupButtonsStackView(_ buttons: [AlertViewButton]) {
//        buttonsStackView.distribution = .fillEqually
//        buttonsStackView.axis = buttons.count > 2 ? .vertical : .horizontal
//        buttonsStackView.backgroundColor = .gray // TODO: - check color
//        buttonsStackView.spacing = 0.5
//        buttons.enumerated().forEach { (index, item) in
//            let button = UIButton()
//            button.constrainHeight(40)
//            button.setTitle(item.title, for: .normal)
//            button.setTitleColor(item.color, for: .normal)
//            button.titleLabel?.font = .customFont(name: .MontserratSemiBold)
//            button.backgroundColor = ._primaryColor
//            button.tap().sink { [weak self] _ in
//                self?.tapPublisher.send(index)
//            }.store(in: &subs)
//            buttonsStackView.addArrangedSubview(button)
//        }
//    }
//}
//
//extension AlertView: BaseView {
//    func addSubviews() {
//        addSubview(titleLabel)
//        addSubview(messageLabel)
//        addSubview(dividerLine)
//        addSubview(buttonsStackView)
//    }
//    
//    func styleSubviews() {
//        backgroundColor = ._primaryColor
//        layer.cornerRadius = 10
//        layer.masksToBounds = true
//    }
//    
//    func positionSubviews() {
//        constrainWidth(266)
//        
//        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 10, bottom: 0, right: 10))
//        
//        messageLabel.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 10))
//        
//        dividerLine.anchor(top: messageLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
//        dividerLine.constrainHeight(0.5)
//        
//        buttonsStackView.anchor(top: dividerLine.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//    }
//}
