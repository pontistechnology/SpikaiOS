//
//  ContactsTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit
import Kingfisher
import Combine

enum ContactsTableViewCellType {
    case normal
    case text(text: String?)
    case remove
    case emoji(emoji: String, size: CGFloat)
    case doubleEntry(firstText: String?, firstImage: AssetName?, secondText: String?, secondImage: AssetName?)
}

class ContactsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "ContactsTableViewCell"
    
    let onRightClickAction = PassthroughSubject<UITableViewCell,Never>()
    var subscriptions = Set<AnyCancellable>()
    
    private let horizontalStackView = CustomStackView(axis: .horizontal, spacing: 12)
    private let leftImageView = RoundedImageView(image: UIImage(safeImage: .userImage))
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setTitleColor(.black, for: .normal)
        button.publisher(for: .touchUpInside)
            .map { [unowned self] _ in self }
            .subscribe(self.onRightClickAction)
            .store(in: &subscriptions)
        return button
    } ()
    
    private let rightView = ContactsCellRightView()
    private let verticalStackView = CustomStackView(axis: .vertical, spacing: 12)
    private let nameLabel = CustomLabel(text: "", textSize: 14, fontName: .MontserratMedium)
    private let descriptionLabel = CustomLabel(text: "CTO", textSize: 12, fontName: .MontserratRegular)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.contentView.addSubview(horizontalStackView)
        self.horizontalStackView.addArrangedSubview(self.leftImageView)
        self.horizontalStackView.addArrangedSubview(self.verticalStackView)
        self.verticalStackView.addArrangedSubview(self.nameLabel)
        self.verticalStackView.addArrangedSubview(self.descriptionLabel)
        
        self.horizontalStackView.addArrangedSubview(self.rightButton)
        self.horizontalStackView.addArrangedSubview(self.rightView)
    }
    
    func styleSubviews() {
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.clipsToBounds = true
        leftImageView.contentMode = .scaleAspectFill
        nameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
        rightView.isHidden = true
    }
    
    func positionSubviews() {
        self.horizontalStackView.constraint(with: UIEdgeInsets(top: 12, left: 20, bottom: -12, right: -20))
        self.leftImageView.widthAnchor.constraint(equalTo: self.leftImageView.heightAnchor).isActive = true
    }
    
    func configureCell(title: String?,
                       description: String?,
                       leftImage: URL?,
                       type: ContactsTableViewCellType) {
        self.nameLabel.text = title
        self.descriptionLabel.text = description
        leftImageView.kf.setImage(with: leftImage, placeholder: UIImage(safeImage: .userImage))
        
        self.rightButton.isHidden = true
        self.rightButton.setImage(nil, for: .normal)
        self.rightButton.setTitle(nil, for: .normal)
        self.rightView.isHidden = true
        
        switch type {
        case .normal:
            break
        case .text(let text):
            self.rightButton.isHidden = false
            self.rightButton.setTitle(text, for: .normal)
        case .remove:
            self.rightButton.isHidden = false
            self.rightButton.setImage(UIImage(safeImage: .close), for: .normal)
        case .emoji(let emoji, let size):
            self.rightButton.isHidden = false
            self.rightButton.titleLabel?.font = UIFont(name: CustomFontName.MontserratRegular.rawValue, size: size)
            self.rightButton.setTitle(emoji, for: .normal)
        case .doubleEntry(let firstText,let firstImage,let secondText,let secondImage):
            self.rightView.isHidden = false
            
            self.rightView.firstRow.label.text = firstText
            if let image = firstImage {
                self.rightView.firstRow.imageView.image = UIImage(safeImage: image)
            }
            
            self.rightView.secondRow.label.text = secondText
            if let image = secondImage {
                self.rightView.secondRow.imageView.image = UIImage(safeImage: image)
            }
        }
    }
    
    override func prepareForReuse() {
        self.leftImageView.image = UIImage(safeImage: .userImage)
        self.nameLabel.text = ""
        self.descriptionLabel.text = ""
    }
}
