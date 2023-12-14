//
//  TableViewHeaderWithIcon.swift
//  Spika
//
//  Created by Vedran Vugrin on 08.05.2023..
//

import UIKit

final class TableViewHeaderWithIcon: UITableViewHeaderFooterView, BaseView {
    
    let stackView = CustomStackView(axis: .horizontal, distribution: .fill, alignment: .center, spacing: 10)
    let icon = UIImageView()
    let title = CustomLabel(text: "Header", textColor: .textPrimary)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
        styleSubviews()
        positionSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(title)
    }
    
    func styleSubviews() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func positionSubviews() {
        stackView.constraint(to: nil, with: UIEdgeInsets(top: 12, left: 20, bottom: -12, right: -20))
    }
    
}
