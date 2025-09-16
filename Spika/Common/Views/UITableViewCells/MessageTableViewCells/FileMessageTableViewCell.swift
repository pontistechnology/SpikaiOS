//
//  FileMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.08.2022..
//

import UIKit

final class FileMessageTableViewCell: BaseMessageTableViewCell2 {
    
    private let fileView = MessageFileView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupFileCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFileCell() {
        containerStackView.addArrangedSubview(fileView)
    }
}

// MARK: Public Functions

extension FileMessageTableViewCell: BaseMessageTableViewCellProtocol {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fileView.reset()
    }
    
    func updateCell(message: Message) {
        let image = UIImage.imageFor(mimeType: message.body?.file?.mimeType ?? "unknown")
        let name  = message.body?.file?.fileName ?? "fileName"
        let size  = Float(message.body?.file?.size ?? 0) / 1000000
        let s = size > 0 ? String(format: "%.2f MB", size) : ""
        fileView.setup(icon: image, name: name, size: s)
        
        fileView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.openFile)
        }.store(in: &subs)
    }
}
