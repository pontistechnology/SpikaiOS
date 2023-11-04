//
//  SharedView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class SharedView: UIView, BaseView {
    
    let testLabel = CustomLabel(text: .getStringFor(.shared), textColor: .checkWithDesign)
    let segmentedControl = SegmentedControl(items: [String.getStringFor(.members), String.getStringFor(.links), String.getStringFor(.docs)])
    let mediaCollectionView = MediaCollectionView()
    let docsTableView = DocsTableView()
    let linksTableView = LinksTableView()
    
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
        addSubview(mediaCollectionView)
        addSubview(docsTableView)
        addSubview(linksTableView)
    }
    
    func styleSubviews() {
        segmentedControl.selectedSegmentTintColor = .checkWithDesign // TODO: - change check
        segmentedControl.tintColor = .checkWithDesign
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor._textPrimary], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.checkWithDesign], for: .selected)
        
        mediaCollectionView.isHidden = segmentedControl.selectedSegmentIndex != 0
        linksTableView.isHidden = segmentedControl.selectedSegmentIndex != 1
        docsTableView.isHidden  = segmentedControl.selectedSegmentIndex != 2
    }
    
    func positionSubviews() {
        testLabel.centerInSuperview()
        segmentedControl.centerXToSuperview()
        segmentedControl.anchor(top: topAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        segmentedControl.constrainWidth(240)
        segmentedControl.constrainHeight(40)
        
        mediaCollectionView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
        
        docsTableView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
        
        linksTableView.anchor(top: segmentedControl.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 12, right: 20))
    }
    
    func setupBindings() {
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged() {
        mediaCollectionView.isHidden = segmentedControl.selectedSegmentIndex != 0
        linksTableView.isHidden = segmentedControl.selectedSegmentIndex != 1
        docsTableView.isHidden  = segmentedControl.selectedSegmentIndex != 2
        
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            linksTableView.reloadData()
        case 2:
            docsTableView.reloadData()
        default:
            break
        }
    } 
}
