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
    
    private let titleLabel = CustomLabel(text: "(no name)", textSize: 14, textColor: .textPrimary, fontName: .RobotoFlexSemiBold)
    private let noteIW = UIImageView(image: UIImage(resource: .rDnotes).withTintColor(.textPrimary, renderingMode: .alwaysOriginal))
    private let rightArrowIW = UIImageView(image: UIImage(resource: .rDrightArrow).withTintColor(.textPrimary, renderingMode: .alwaysOriginal))
    private let emptyView = UIView()
    
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
        contentView.addSubview(emptyView)
        emptyView.addSubview(noteIW)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(rightArrowIW)
    }
    
    func styleSubviews() {
        emptyView.backgroundColor = .primaryColor
        backgroundColor = .clear
        noteIW.contentMode = .scaleAspectFit
    }
    
    func positionSubviews() {
        emptyView.fillSuperview(padding: .init(top: 4, left: 4, bottom: 4, right: 4))
        noteIW.centerYToSuperview()
        noteIW.anchor(leading: emptyView.leadingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: CGSizeMake(24, 24))

        rightArrowIW.centerYToSuperview()
        rightArrowIW.anchor(trailing: emptyView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16))
        
        titleLabel.anchor(leading: noteIW.trailingAnchor, trailing: emptyView.trailingAnchor, padding: .init(top: 0, left: 11, bottom: 0, right: 40))
        titleLabel.centerYToSuperview()
        
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        roundCorners(corners: .allCorners, radius: 15)
    }
}
