//
//  VoiceMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class VoiceMessageTableViewCell: UITableViewCell, BaseView {
   
    static let reuseIdentifier = "VoiceMessageTableViewCell"
    
    let voiceMessageView = VoiceMessageView(duration: 0)
    let messageStateView = MessageStateView(state: .waiting)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(voiceMessageView)
        contentView.addSubview(messageStateView)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        voiceMessageView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        messageStateView.anchor(top: voiceMessageView.bottomAnchor, trailing: voiceMessageView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        let bottomAnchor = messageStateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        bottomAnchor.priority = .defaultLow
        bottomAnchor.isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
