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
    private let timeLabel = CustomLabel(text: "time", textSize: 12, textColor: .textSecondary, fontName: .MontserratMedium)
    
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 14, left: 20, bottom: 0, right: 52))
        
        timeLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func configureCell(title: String, timeText: String) {
        titleLabel.text = title
        timeLabel.text  = timeText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        timeLabel.text = nil
    }
}
