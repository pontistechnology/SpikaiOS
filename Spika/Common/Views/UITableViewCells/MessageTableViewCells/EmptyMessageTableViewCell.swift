//
//  EmptyMessageCell().swift
//  Spika
//
//  Created by Nikola Barbarić on 20.10.2022..
//

import Foundation
import UIKit

class EmptyMessageTableViewCell: UITableViewCell {
    
    static let emptyReuseIdentifier = "EmptyMessageTableViewCell"
    
    let messageTextView = CustomTextView(text: "Empty Cell - report this", textSize: 14, textColor: .logoBlue, fontName: .MontserratMedium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        print("CELL INTI: ", style.rawValue, "reuse identifieer: ", reuseIdentifier)
        setupEmptyCell()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("textcell deinit")
    }
    
    func setupEmptyCell() {
        contentView.backgroundColor = .cyan
        contentView.addSubview(messageTextView)
        
        messageTextView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 2, right: 0))
    }
}
