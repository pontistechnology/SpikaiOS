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
    case doubleEntry(firstText: String?, firstImage: ImageResource?, secondText: String?, secondImage: ImageResource?)
}

class ContactsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier = "ContactsTableViewCell"
    
    let onRightClickAction = PassthroughSubject<UITableViewCell,Never>()
    var subscriptions = Set<AnyCancellable>()
    
    private let horizontalStackView = CustomStackView(axis: .horizontal, alignment: .center, spacing: 12)
    private let leftImageView = RoundedImageView(image: UIImage(resource: .rDdefaultUser))
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.publisher(for: .touchUpInside)
            .map { [unowned self] _ in self }
            .subscribe(onRightClickAction)
            .store(in: &subscriptions)
        return button
    } ()
    
    private let rightView = ContactsCellRightView()
    private let verticalStackView = CustomStackView(axis: .vertical, spacing: 2)
    private let nameLabel = CustomLabel(text: "", textSize: 14, textColor: .textPrimary, fontName: .RobotoFlexMedium)
    private let descriptionLabel = CustomLabel(text: " ", textSize: 12, textColor: .textPrimary, fontName: .RobotoFlexRegular)
    private let dummyView = UIView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(leftImageView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
        
        horizontalStackView.addArrangedSubview(rightButton)
        horizontalStackView.addArrangedSubview(rightView)
    }
    
    func styleSubviews() {
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.clipsToBounds = true
        leftImageView.contentMode = .scaleAspectFill
        nameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
        backgroundColor = .clear
        rightView.hide()
    }
    
    func positionSubviews() {
        horizontalStackView.constraint(with: UIEdgeInsets(top: 12, left: 20, bottom: -12, right: -20))
        leftImageView.widthAnchor.constraint(equalTo: leftImageView.heightAnchor).isActive = true
    }
    
    func configureCell(title: String?,
                       description: String?,
                       leftImage: URL?,
                       type: ContactsTableViewCellType) {
        nameLabel.text = title
        descriptionLabel.text = description
        leftImageView.kf.setImage(with: leftImage, placeholder: UIImage(resource: .rDdefaultUser))
        
        rightButton.hide()
        rightButton.setImage(nil, for: .normal)
        rightButton.setTitle(nil, for: .normal)
        rightView.hide()
        
        switch type {
        case .normal:
            break
        case .text(let text):
            rightButton.unhide()
            rightButton.setTitle(text, for: .normal)
            rightButton.titleLabel?.font = UIFont(name: CustomFontName.RobotoFlexLight.rawValue, size: 14)
            rightButton.setTitleColor(.textPrimary, for: .normal)
        case .remove:
            rightButton.unhide()
            rightButton.setImage(UIImage(resource: .rDx).withTintColor(.tertiaryColor, renderingMode: .alwaysOriginal), for: .normal)
        case .emoji(let emoji, let size):
            rightButton.unhide()
            rightButton.titleLabel?.font = UIFont(name: CustomFontName.RobotoFlexRegular.rawValue, size: size)
            rightButton.setTitle(emoji, for: .normal)
        case .doubleEntry(let firstText,let firstImage,let secondText,let secondImage):
            rightView.unhide()
            
            rightView.firstRow.label.text = firstText
            if let image = firstImage {
                rightView.firstRow.imageView.image = UIImage(resource: image)
            }
            
            rightView.secondRow.label.text = secondText
            if let image = secondImage {
                rightView.secondRow.imageView.image = UIImage(resource: image)
            }
        }
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(resource: .rDdefaultUser)
        nameLabel.text = ""
        descriptionLabel.text = ""
    }
}
