//
//  BaseSettingsView.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import UIKit

class BaseSettingsView: UIView, BaseView {
        
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private let contentView = UIView()
    
    let mainStackView = CustomStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.mainStackView)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        self.scrollView.fillSuperview()
        
        self.contentView.anchor(top: self.scrollView.contentLayoutGuide.topAnchor,
                                leading: self.scrollView.contentLayoutGuide.leadingAnchor,
                                bottom: self.scrollView.contentLayoutGuide.bottomAnchor,
                                trailing: self.scrollView.contentLayoutGuide.trailingAnchor)
        self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.mainStackView.constraintLeading()
        self.mainStackView.constraintTrailing()
        self.mainStackView.constraintTop(to: nil, constant: 24)
        self.mainStackView.constraintBottom()
    }
    
}
