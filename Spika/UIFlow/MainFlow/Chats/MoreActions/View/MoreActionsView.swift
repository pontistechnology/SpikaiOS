//
//  MoreActionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.12.2022..
//
import Combine
import UIKit

enum MoreActions { // TODO: move
    case files
    case library
    case location
    case contact
    case close
}

class MoreActionsView: UIView {
    private let containerView = UIView()
    
    let transparentView = UIView()
    
    private let moreActionsLabel = CustomLabel(text: "More actions", textSize: 16, textColor: .textPrimary, fontName: .RobotoFlexSemiBold)
    private let optionsStackView = CustomStackView(axis: .horizontal, distribution: .fillEqually, spacing: 12)
    let filesImageView = UIImageView(image: UIImage(resource: .files))
    let libraryImageView = UIImageView(image: UIImage(resource: .library))
    let locationImageView = UIImageView(image: UIImage(resource: .location))
    let contactImageView = UIImageView(image: UIImage(resource: .contact))
    let closeImageView = UIImageView(image: UIImage(resource: .rDx).withTintColor(.tertiaryColor, renderingMode: .alwaysOriginal))
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MoreActionsView: BaseView {
    func addSubviews() {
        addSubview(transparentView)
        addSubview(containerView)
        containerView.addSubview(moreActionsLabel)
        containerView.addSubview(optionsStackView)
        containerView.addSubview(closeImageView)
        optionsStackView.addArrangedSubview(filesImageView)
        optionsStackView.addArrangedSubview(libraryImageView)
        optionsStackView.addArrangedSubview(locationImageView)
        optionsStackView.addArrangedSubview(contactImageView)
    }
    
    func styleSubviews() {
        transparentView.backgroundColor = .clear
        containerView.backgroundColor = .secondaryColor // TODO: - check
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        filesImageView.contentMode = .scaleAspectFit
        libraryImageView.contentMode = .scaleAspectFit
        locationImageView.contentMode = .scaleAspectFit
        contactImageView.contentMode = .scaleAspectFit
        closeImageView.contentMode = .scaleAspectFit
    }
    
    func positionSubviews() {
        containerView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        transparentView.anchor(top: topAnchor, leading: leadingAnchor, bottom: containerView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        closeImageView.anchor(top: containerView.topAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 25))
        
        moreActionsLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 0))
        
        optionsStackView.anchor(top: moreActionsLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 16, bottom: 74, right: 16))
        optionsStackView.constrainHeight(72)
    }
}
