//
//  CountryTableViewCell.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class CountryTableViewCell: UITableViewCell, BaseView {
    
    let countryImage = UIImageView()
    let countryNameLabel = CustomLabel(text: "", textColor: .textPrimary)
    let countryCodeLabel = CustomLabel(text: "", textSize: 12, textColor: ._textSecondary, fontName: .MontserratRegular, alignment: .right)
    
    static let cellIdentifier = "CountryTableViewCell"
    static let rowHeight: CGFloat = 50.0
    
    func addSubviews() {
        addSubview(countryImage)
        addSubview(countryCodeLabel)
        addSubview(countryNameLabel)
    }
    
    func styleSubviews() {
        selectionStyle = .none
//        backgroundColor = ._secondaryColor // TODO: - check
    }
    
    func positionSubviews() {
        countryImage.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 30, height: 25))
        countryImage.centerY(inView: self)
        
        countryCodeLabel.anchor(trailing: trailingAnchor)
        countryCodeLabel.constrainWidth(50)
        countryCodeLabel.centerY(inView: self)
        
        countryNameLabel.anchor(leading: countryImage.trailingAnchor, trailing: countryCodeLabel.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        countryNameLabel.centerY(inView: self)
    }
    
    func setup(with country: Country) {
        setupView()
        countryCodeLabel.text = country.phoneCode
        countryNameLabel.text = country.name
        countryImage.image = country.flag
    }
}
