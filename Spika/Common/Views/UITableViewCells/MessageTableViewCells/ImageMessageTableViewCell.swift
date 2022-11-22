//
//  ImageMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.07.2022..
//

import Foundation
import UIKit

final class ImageMessageTableViewCell: BaseMessageTableViewCell {
    
    private let photoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImageCell()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("textcell deinit")
    }
    
    func setupImageCell() {
        containerView.addSubview(photoImageView)
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
        
        photoImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        photoImageView.heightAnchor.constraint(equalToConstant: 256).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: 256).isActive  = true
    }
}
// MARK: Public Functions

extension ImageMessageTableViewCell {
    
    func updateCell(message: Message) {
        photoImageView.kf.setImage(with: message.body?.file?.path?.getFullUrl(), placeholder: UIImage(systemName: "arrow.counterclockwise")?.withTintColor(.gray, renderingMode: .alwaysOriginal)) // TODO: change image
        
        photoImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.openImage)
        }.store(in: &subs)
    }
    
    func setupBindings() {
        
    }
}
