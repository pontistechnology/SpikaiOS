//
//  MoreActionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.12.2022..
//
import Combine
import UIKit

enum MoreActions {
    case files
    case library
    case location
    case contact
    case close
}

class MoreActionsView: UIView {
    private let containerView = UIView(backgroundColor: .white)
    
    private let moreActionsLabel = CustomLabel(text: "More actions", textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    private let optionsStackView = CustomStackView(axis: .horizontal, distribution: .fillEqually, spacing: 12)
    private let filesImageView = UIImageView(image: UIImage(safeImage: .files))
    private let libraryImageView = UIImageView(image: UIImage(safeImage: .library))
    private let locationImageView = UIImageView(image: UIImage(safeImage: .location))
    private let contactImageView = UIImageView(image: UIImage(safeImage: .contact))
    private let closeImageView = UIImageView(image: UIImage(safeImage: .closeMoreActions))
    
    let publisher = PassthroughSubject<MoreActions, Never>()
    private var subs = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MoreActionsView: BaseView {
    func addSubviews() {
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
        containerView.backgroundColor = .appWhite
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
        
        closeImageView.anchor(top: containerView.topAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 25))
        
        moreActionsLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 0))
        
        optionsStackView.anchor(top: moreActionsLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 16, bottom: 74, right: 16))
        optionsStackView.constrainHeight(72)
    }
}

private extension MoreActionsView {
    func setupBindings() {
        closeImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.close)
        }.store(in: &subs)
        
        filesImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.files)
        }.store(in: &subs)
        
        libraryImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.library)
        }.store(in: &subs)
        
        contactImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.contact)
        }.store(in: &subs)
        
        locationImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.location)
        }.store(in: &subs)
    }
}
