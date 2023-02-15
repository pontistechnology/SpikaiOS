//
//  UserBlockedView.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import UIKit
import Combine

class UserBlockedView: UIView, BaseView {
    
    let verticalStackView = CustomStackView()
    let label = CustomLabel(text: .getStringFor(.youBlockedTheContact), textSize: 16, textColor: .textPrimary, alignment: .center)
    let horizontalStackView = CustomStackView(axis: .horizontal, distribution: .fillEqually, spacing: 18)
    let blockUnblockButton = MainButton()
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleSubviews() {
        self.isHidden = true
        self.backgroundColor = .textTertiary
        self.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        blockUnblockButton.backgroundColor = .primaryBackground
        blockUnblockButton.setTitleColor(.textPrimary, for: .normal)
        blockUnblockButton.setTitle(.getStringFor(.unblock), for: .normal)
    }
    
    func positionSubviews() {
        self.verticalStackView.constraint(to: nil, with: UIEdgeInsets(top: 22, left: 22, bottom: -42, right: -22))
    }
    
    func addSubviews() {
        self.addSubview(self.verticalStackView)
        self.verticalStackView.addArrangedSubview(self.label)
        self.verticalStackView.addArrangedSubview(self.horizontalStackView)
        self.horizontalStackView.addArrangedSubview(self.blockUnblockButton)
    }
    
}
