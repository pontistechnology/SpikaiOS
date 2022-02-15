//
//  SharedView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class SharedView: UIView, BaseView {
    
    let testLabel = CustomLabel(text: "shared")
    let segmentedControl = SegmentedControl(items: ["Media", "Links", "Docs"])
    let mediaView = MediaView()
    let docsView = DocsView()
    let linksView = LinksView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(testLabel)
        addSubview(segmentedControl)
        addSubview(mediaView)
        addSubview(docsView)
        addSubview(linksView)
    }
    
    func styleSubviews() {
        segmentedControl.selectedSegmentTintColor = .appBlueLight
        segmentedControl.tintColor = .chatBackground
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.textPrimary], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.primaryColor], for: .selected)
        
        mediaView.isHidden = segmentedControl.selectedSegmentIndex != 0
        linksView.isHidden = segmentedControl.selectedSegmentIndex != 1
        docsView.isHidden  = segmentedControl.selectedSegmentIndex != 2
    }
    
    func positionSubviews() {
        testLabel.centerInSuperview()
        segmentedControl.centerXToSuperview()
        segmentedControl.anchor(top: topAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        segmentedControl.constrainWidth(240)
        segmentedControl.constrainHeight(40)
        
        mediaView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
        
        docsView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
        
        linksView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
    }
    
    func setupBindings() {
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged() {
        mediaView.isHidden = segmentedControl.selectedSegmentIndex != 0
        linksView.isHidden = segmentedControl.selectedSegmentIndex != 1
        docsView.isHidden  = segmentedControl.selectedSegmentIndex != 2
        
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            linksView.tableView.reloadData()
        case 2:
            docsView.tableView.reloadData()
        default:
            break
        }
    } 
}
