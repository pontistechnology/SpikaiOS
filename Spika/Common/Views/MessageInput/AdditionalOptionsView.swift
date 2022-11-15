//
//  AdditionalOptionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.08.2022..
//

import Foundation
import UIKit
import Combine

enum AdditionalOptionsViewState {
    case files
    case library
    case location
    case contact
}

class AdditionalOptionsView: UIView {
    private let moreActionsLabel = CustomLabel(text: "More actions", textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    private let optionsStackView = UIStackView()
    private let filesImageView = UIImageView(image: UIImage(safeImage: .files))
    private let libraryImageView = UIImageView(image: UIImage(safeImage: .library))
    private let locationImageView = UIImageView(image: UIImage(safeImage: .location))
    private let contactImageView = UIImageView(image: UIImage(safeImage: .contact))
    private let coverView = UIView()
    private let contentView = UIView()
    
    private var subs = Set<AnyCancellable>()
    let publisher = PassthroughSubject<AdditionalOptionsViewState, Never>()
    
    init(){
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdditionalOptionsView: BaseView {
    func addSubviews() {
        addSubview(contentView)
        contentView.addSubview(moreActionsLabel)
        contentView.addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(filesImageView)
        optionsStackView.addArrangedSubview(libraryImageView)
        optionsStackView.addArrangedSubview(locationImageView)
        optionsStackView.addArrangedSubview(contactImageView)
        contentView.addSubview(coverView)
    }
    
    func styleSubviews() {
        backgroundColor = .gray.withAlphaComponent(0.5)
        contentView.backgroundColor = .appWhite
        coverView.backgroundColor = .appWhite
        contentView.layer.cornerRadius = 10
        filesImageView.contentMode = .scaleAspectFit
        libraryImageView.contentMode = .scaleAspectFit
        locationImageView.contentMode = .scaleAspectFit
        contactImageView.contentMode = .scaleAspectFit
        optionsStackView.axis = .horizontal
        optionsStackView.distribution = .fillEqually
    }
    
    func positionSubviews() {
        contentView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        contentView.constrainHeight(152)
        
        moreActionsLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 0))
        
        optionsStackView.anchor(top: moreActionsLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 16, bottom: 0, right: 16))
        optionsStackView.constrainHeight(72)
        
        coverView.anchor(leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        coverView.constrainHeight(10)
        
        constrainHeight(1000)
    }
}

extension AdditionalOptionsView {
    private func setupBindings() {
        libraryImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.library)
        }.store(in: &subs)
        
        filesImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.files)
        }.store(in: &subs)
        
        locationImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.location)
        }.store(in: &subs)
        
        contactImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.contact)
        }.store(in: &subs)
    }
}
