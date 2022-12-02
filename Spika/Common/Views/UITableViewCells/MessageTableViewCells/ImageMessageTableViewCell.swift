//
//  ImageMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.07.2022..
//

import Foundation
import UIKit

final class ImageMessageTableViewCell: BaseMessageTableViewCell {
    
    private let photoImageView = MessageImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImageCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("textcell deinit")
    }
    
    func setupImageCell() {
        containerStackView.addArrangedSubview(photoImageView)
    }
}
// MARK: Public Functions

extension ImageMessageTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.reset()
    }
    
    func updateCell(message: Message) {
        photoImageView.setImage(url: message.body?.file?.path?.getFullUrl())
        
        photoImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.openImage)
        }.store(in: &subs)
    }
}
