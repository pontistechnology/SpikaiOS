//
//  SettingsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class SettingsView: UIView, BaseView {
    
//    let titleLabel = UILabel()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    let contentView = SettingsContentView(frame: .zero)
    
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
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        self.scrollView.fillSuperview()
        
        self.contentView.anchor(top: self.scrollView.contentLayoutGuide.topAnchor,
                                leading: self.scrollView.contentLayoutGuide.leadingAnchor,
                                bottom: self.scrollView.contentLayoutGuide.bottomAnchor,
                                trailing: self.scrollView.contentLayoutGuide.trailingAnchor)
        self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
}
