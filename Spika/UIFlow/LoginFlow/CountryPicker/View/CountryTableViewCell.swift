//
//  CountryTableViewCell.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class CountryTableViewCell: UITableViewCell, BaseView {
    
    let countryNameLabel = UILabel()
    let countryCodeLabel = UILabel()
    
    static let cellIdentifier = "CountryTableViewCell"
    static let rowHeight: CGFloat = 50.0
    
    func addSubviews() {
        addSubview(countryCodeLabel)
        addSubview(countryNameLabel)
    }
    
    func styleSubviews() {
        self.selectionStyle = .none
        
        countryNameLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
        
        countryCodeLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
        countryCodeLabel.textColor = UIColor(named: Constants.Colors.appGray)
        countryCodeLabel.textAlignment = .right
        
    }
    
    func positionSubviews() {
        countryCodeLabel.anchor(trailing: trailingAnchor)
        countryCodeLabel.constrainWidth(50)
        countryCodeLabel.centerY(inView: self)
        
        countryNameLabel.anchor(leading: leadingAnchor, trailing: countryCodeLabel.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        countryNameLabel.centerY(inView: self)
    }
    
    func setup(with country: Country) {
        setupView()
        countryCodeLabel.text = country.phoneCode
        countryNameLabel.text = country.name
    }
}
