//
//  ReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.01.2023..
//

import Foundation
import UIKit

class ReactionsView: UIView {
    private let label = CustomLabel(text: .getStringFor(.reactions), textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    let closeImageView = UIImageView(image: UIImage(safeImage: .closeActionsSheet))
    let tableView = UITableView()
    let stackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setupView()
        tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: ContactsTableViewCell.reuseIdentifier)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReactionsView: BaseView {
    func addSubviews() {
        addSubview(label)
        addSubview(closeImageView)
        addSubview(tableView)
        addSubview(stackView)
    }
    
    func styleSubviews() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
//        stackView.backgroundColor = .logoBlue
    }
    
    func positionSubviews() {
        closeImageView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 25))
        
        label.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 25, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        stackView.constrainHeight(60)

        tableView.anchor(top: label.bottomAnchor, leading: leadingAnchor, bottom: stackView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
}

extension ReactionsView {
    func setupStackView() {
        let a = ["😂","😇","😍","😘","❤️"]
        let aa = CustomLabel(text: "ALL", textSize: 16, alignment: .center)
        stackView.addArrangedSubview(aa)
        for i in 0...4 {
            let a = CustomLabel(text: a[i], textSize: 16, alignment: .center)
            stackView.addArrangedSubview(a)
        }
    }
}
