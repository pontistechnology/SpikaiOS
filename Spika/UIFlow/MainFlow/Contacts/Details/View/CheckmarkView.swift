//
//  CheckmarkView.swift
//  Spika
//
//  Created by Vedran Vugrin on 08.05.2023..
//

import UIKit

final class CheckmarkView: UIButton, BaseView {
    
    let stackView = CustomStackView(axis: .horizontal, distribution: .fill, alignment: .center, spacing: 10)
    let label = CustomLabel(text: "text")
    let checkmark = UIImageView(image: UIImage(safeImage: .checkmark))
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateIsSelected(isSelected: Bool) {
        checkmark.isHidden = !isSelected
    }
    
    func addSubviews() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(checkmark)
    }
    
    func styleSubviews() {
        label.text = text
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.contentMode = .scaleAspectFit
        checkmark.hide()
    }
    
    func positionSubviews() {
        stackView.constraint(to: nil, with: UIEdgeInsets(top: 12, left: 20, bottom: -12, right: -20))
        checkmark.constrainWidth(24)
        checkmark.constrainHeight(24)
        
//        label.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
//        label.centerYToSuperview()
//
//        self.constrainHeight(80)
    }
    
}
