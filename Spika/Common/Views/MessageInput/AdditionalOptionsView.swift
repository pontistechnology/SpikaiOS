//
//  AdditionalOptionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.08.2022..
//

import Foundation
import UIKit

class AdditionalOptionsView: UIView {
    private let moreActionsLabel = CustomLabel(text: "More actions", textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    private let optionsStackView = UIStackView()
    let filesImageView = UIImageView(image: UIImage(named: "files"))
    let libraryImageView = UIImageView(image: UIImage(named: "library"))
    let locationImageView = UIImageView(image: UIImage(named: "location"))
    let contactImageView = UIImageView(image: UIImage(named: "contact"))
    
    init(){
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdditionalOptionsView: BaseView {
    func addSubviews() {
        addSubview(moreActionsLabel)
        addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(filesImageView)
        optionsStackView.addArrangedSubview(libraryImageView)
        optionsStackView.addArrangedSubview(locationImageView)
        optionsStackView.addArrangedSubview(contactImageView)
    }
    
    func styleSubviews() {
        backgroundColor = .lightGray
        filesImageView.contentMode = .scaleAspectFit
        libraryImageView.contentMode = .scaleAspectFit
        locationImageView.contentMode = .scaleAspectFit
        contactImageView.contentMode = .scaleAspectFit
        optionsStackView.axis = .horizontal
        optionsStackView.distribution = .fillEqually
    }
    
    func positionSubviews() {
        moreActionsLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 0))
        
        optionsStackView.anchor(top: moreActionsLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 18, left: 16, bottom: 24, right: 16))
    }
}
