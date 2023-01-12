//
//  UserBlockedView.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import UIKit
import Combine

final class UserBlockedView: UIView, BaseView {
    
    let verticalStackView = CustomStackView()
    let label = CustomLabel(text: .getStringFor(.youBlockedTheContact), textSize: 18, textColor: .white, alignment: .center)
    let unblockButton = MainButton()
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        self.isHidden = true
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleSubviews() {
        self.backgroundColor = .lightGray
        self.translatesAutoresizingMaskIntoConstraints = false
        unblockButton.backgroundColor = .white
        unblockButton.setTitleColor(.black, for: .normal)
        unblockButton.setTitle(.getStringFor(.unblock), for: .normal)
    }
    
    func positionSubviews() {
        self.verticalStackView.constraint(to: nil, with: UIEdgeInsets(top: 22, left: 22, bottom: -42, right: -22))
    }
    
    func addSubviews() {
        self.addSubview(self.verticalStackView)
        self.verticalStackView.addArrangedSubview(self.label)
        self.verticalStackView.addArrangedSubview(self.unblockButton)
    }
    
}
