//
//  NoteTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import UIKit

class NoteTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "NoteTableViewCell"
    
    private let titleLabel = CustomLabel(text: "(no name)", textSize: 14, textColor: .textPrimary, fontName: .MontserratMedium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteTableViewCell {
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        titleLabel.anchor(leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        titleLabel.centerYToSuperview()
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
