//
//  CustomReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation
import UIKit

class CustomReactionsView: UIView {
    
    let searchBar = UISearchBar()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let categoriesView: EmojiCategoriesView
    
    init(emojiSections: [EmojiSection]) {
        self.categoriesView = EmojiCategoriesView(emojiSections: emojiSections)
        super.init(frame: .zero)
        setupView()
        collectionView.register(CustomReactionCollectionViewCell.self, forCellWithReuseIdentifier: CustomReactionCollectionViewCell.reuseIdentifier)
        collectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var calculatedSpacing: CGFloat {
        let numberOfCellsInOneRow: CGFloat = 7 // change this only
        return (collectionView.frame.width - numberOfCellsInOneRow * CustomReactionCollectionViewCell.widthOrHeight) / (numberOfCellsInOneRow - 1)
    }
}

extension CustomReactionsView: BaseView {
    func addSubviews() {
        addSubview(searchBar)
        addSubview(collectionView)
        addSubview(categoriesView)
    }
    
    func styleSubviews() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = .getStringFor(.searchForReaction)
    }
    
    func positionSubviews() {
        searchBar.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 12, bottom: 0, right: 12))
        collectionView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: categoriesView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20))
        categoriesView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        categoriesView.constrainHeight(50)
    }
}

extension CustomReactionsView {
    func scrollToSection(_ section: Int) {
        collectionView.layoutIfNeeded()
        let indexPath = IndexPath(row: 0, section: section)
        if let attributes =  collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
            let topOfHeader = CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            collectionView.setContentOffset(topOfHeader, animated: true)
        }
    }
}
