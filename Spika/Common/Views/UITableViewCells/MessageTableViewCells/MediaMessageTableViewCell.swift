//
//  MediaMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class MediaMessageTableViewCell: UITableViewCell, BaseView {
    
    static let reuseIdentifier = "MediaMessageTableViewCell"
    static let seenViewHeight  = 20.0
    static let portraitMediaHeight = 240.0
    static let landscapeMediaHeight = 140.0
    static let replyViewPadding = 20.0
    
    private var replyView: ReplyMessageView?
    private var messageStateView = MessageStateView(state: .waiting)
    
    let mediaImageView = UIImageView(image: UIImage(named: "leaf"))
    
    var replyId: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(mediaImageView)
        contentView.addSubview(messageStateView)
    }
    
    func styleSubviews() {
        mediaImageView.layer.cornerRadius  = 10
        mediaImageView.layer.masksToBounds = true
    }
        
    func positionSubviews() {
        mediaImageView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 140, height: 246))
        messageStateView.anchor(top: mediaImageView.bottomAnchor, trailing: mediaImageView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        let bottomAnchor = messageStateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        bottomAnchor.priority = .defaultLow
        bottomAnchor.isActive = true
    }
  
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
