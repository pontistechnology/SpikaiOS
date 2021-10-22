//
//  SegmentedControl.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

protocol SegmentedControlDelegate: AnyObject {
    func valueDidChange(_ segmentedControl: SegmentedControl, selectedSegmentIndex: Int)
}

class SegmentedControl: UISegmentedControl {
    
    weak var delegate: SegmentedControlDelegate?
    
    override init(items: [Any]?) {
        super.init(items: items)
        setupControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupControl() {
        selectedSegmentIndex = 0
        backgroundColor = UIColor.clear
        selectedSegmentTintColor = UIColor(named: Constants.Colors.appBlueLight)
         
        SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Colors.appBlue)!, NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14)!], for: .selected)
         
        SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14)!], for: .normal)
        
        addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
        delegate?.valueDidChange(self, selectedSegmentIndex: segmentedControl.selectedSegmentIndex)
    }
    
}
