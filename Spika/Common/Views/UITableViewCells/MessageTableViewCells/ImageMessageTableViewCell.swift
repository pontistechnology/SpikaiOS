//
//  ImageMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.07.2022..
//

import Foundation
import UIKit

final class ImageMessageTableViewCell: BaseMessageTableViewCell2 {
    
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

extension ImageMessageTableViewCell: BaseMessageTableViewCellProtocol {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.reset()
    }
    
    func updateCell(message: Message) {
        let imageRatio = ImageRatio(width: message.body?.file?.metaData?.width ?? 1,
                                    height: message.body?.file?.metaData?.height ?? 1)
        
        // TODO: - use repository
        if let localId = message.localId,
           let localPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(localId.appending("thumb")).path,
           FileManager.default.fileExists(atPath: localPath) {
            photoImageView.setImage(path: localPath, as: imageRatio)
        } else {
            let path = message.body?.thumb?.id?.fullFilePathFromId()
            photoImageView.setImage(url: path, as: imageRatio)            
        }
        
        photoImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.openImage)
        }.store(in: &subs)
    }
}
