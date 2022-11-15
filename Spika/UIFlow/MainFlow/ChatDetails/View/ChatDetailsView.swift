//
//  ChatDetailsView.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit

class ChatDetailsView: UIView, BaseView {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    let contentView = ChatContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        positionSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
