//
//  ReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.01.2023..
//

import Foundation
import UIKit
import Combine

class ReactionsView: UIView {
    let tableView = UITableView()
    private let label = CustomLabel(text: .getStringFor(.reactions), textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    private let closeImageView = UIImageView(image: UIImage(safeImage: .closeActionsSheet))
    private let stackView = UIStackView()
    
    let stackviewTapPublisher = PassthroughSubject<String, Never>()
    private var subs = Set<AnyCancellable>()
    
    init(categories: [String]) {
        super.init(frame: .zero)
        setupView()
        tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: ContactsTableViewCell.reuseIdentifier)
        setupStackView(categories)
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
    func setupStackView(_ elements: [String]) {
        elements.forEach {
            let label = CustomLabel(text: $0, textSize: 16, alignment: .center)
            let fL = $0.firstLetter()
            label.tap().sink { [weak self] _ in
                self?.stackviewTapPublisher.send(fL)
            }.store(in: &subs)
            stackView.addArrangedSubview(label)
        }
    }
}
