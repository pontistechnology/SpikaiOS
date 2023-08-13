//
//  CustomReactionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation
import UIKit
import Combine

class CustomReactionsViewController: BaseViewController {
    private lazy var mainView = CustomReactionsView(emojiSections: viewModel.sections)
    var viewModel: CustomReactionsViewModel!
    
    let selectedEmojiPublisher = PassthroughSubject<String, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
        setupBindings()
    }
    
    func setupBindings() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        mainView.categoriesView.selectedSection.sink { [weak self] index in
            self?.mainView.scrollToSection(index)
            self?.mainView.categoriesView.selectCategory(at: index)
        }.store(in: &subscriptions)
    }
}

extension CustomReactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 0, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath)
        (headerView as? CollectionViewHeader)?.configureView(title: viewModel.sections[indexPath.section].title)
        return headerView
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.emojiArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomReactionCollectionViewCell.reuseIdentifier, for: indexPath)
        (cell as? CustomReactionCollectionViewCell)?.configureCell(emoji: viewModel.emojiArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmojiPublisher.send(viewModel.emojiArray[indexPath.row])
        dismiss(animated: true)
    }
}

extension CustomReactionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let squareSize = CustomReactionCollectionViewCell.widthOrHeight
        return CGSize(width: squareSize, height: squareSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return mainView.calculatedSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return mainView.calculatedSpacing
    }
}

extension CustomReactionsViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = mainView.collectionView.indexPathsForVisibleItems.first?.section
        else { return }
        mainView.categoriesView.selectCategory(at: index)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let index = mainView.collectionView.indexPathsForVisibleItems.first?.section
        else { return }
        mainView.categoriesView.selectCategory(at: index)
    }
}
