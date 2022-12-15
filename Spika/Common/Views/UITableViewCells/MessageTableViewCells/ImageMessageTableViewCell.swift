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
        let imageRatio: ImageRatio
        let width = Float(message.body?.thumb?.metaData?.width ?? 1)
        let height = Float(message.body?.thumb?.metaData?.height ?? 1)
        let ratio = width / height
        print("DIF: ", ratio, width, height)
        if 0.75...1.25 ~= ratio {
            imageRatio = .square
        } else if ratio > 1.25 {
            imageRatio = .landscape
        } else {
            imageRatio = .portrait
        }
        
        photoImageView.setImage(url: message.body?.thumb?.path?.getFullUrl(), as: imageRatio)
        
        photoImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.openImage)
            print("dif: ratio ", ratio, imageRatio)
        }.store(in: &subs)
    }
}
