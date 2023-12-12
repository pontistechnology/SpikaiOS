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
    let closeImageView = UIImageView(image: UIImage(resource: .rDx).withTintColor(.tertiaryColor, renderingMode: .alwaysOriginal))
    private let stackView = UIStackView()
    
    let stackviewTapPublisher = CurrentValueSubject<Int, Never>(0)
    private var subs = Set<AnyCancellable>()
    
    init(emojisAndCounts: [String]) {
        super.init(frame: .zero)
        setupView()
        tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: ContactsTableViewCell.reuseIdentifier)
        setupStackView(emojisAndCounts)
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
        backgroundColor = .secondaryColor
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    func positionSubviews() {
        closeImageView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 25))
        
        label.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 25, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        stackView.constrainHeight(60)

        tableView.anchor(top: label.bottomAnchor, leading: leadingAnchor, bottom: stackView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
}

private extension ReactionsView {
    func setupStackView(_ elements: [String]) {
        for (index, element) in elements.enumerated() {
            let label = CustomLabel(text: element, textSize: 16, textColor: .textPrimary, alignment: .center)
            label.tap().sink { [weak self] _ in
                self?.deleteBackgroundOfAllStackSubviews()
                label.backgroundColor = .primaryColor
                self?.stackviewTapPublisher.send(index)
            }.store(in: &subs)
            if index == 0 {
                label.backgroundColor = .primaryColor
            }
            stackView.addArrangedSubview(label)
        }
    }
    
    func deleteBackgroundOfAllStackSubviews() {
        stackView.arrangedSubviews.forEach { $0.backgroundColor = .clear }
    }
}
