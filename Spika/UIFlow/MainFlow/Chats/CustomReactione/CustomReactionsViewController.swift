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
    private lazy var mainView = CustomReactionsView(emojiSections: EmojiSection.allCases)
    var viewModel: CustomReactionsViewModel
    var actions: [UIAction]?
    
    let selectedEmojiPublisher = PassthroughSubject<String, Never>()
    
    init(viewModel: CustomReactionsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
        setupBindings()
        viewModel.getEmojis()
        mainView.collectionView.reloadData()
        view.backgroundColor = ._secondaryColor // TODO: - check
    }
    
    func setupBindings() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        mainView.categoriesView.selectedSection.sink { [weak self] index in
            self?.mainView.scrollToSection(index)
            self?.mainView.categoriesView.selectCategory(at: index)
        }.store(in: &subscriptions)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.15
        mainView.collectionView.addGestureRecognizer(longPress)
    }
}

extension CustomReactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 0, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath)
        let title = indexPath.section < EmojiSection.allCases.count
        ? EmojiSection.allCases[indexPath.section].title
        : .getStringFor(.unknownSection)
        (headerView as? CollectionViewHeader)?.configureView(title: title)
        return headerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.allEmojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allEmojis[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomReactionCollectionViewCell.reuseIdentifier, for: indexPath)
        let emoji = viewModel.allEmojis[indexPath.section][indexPath.row]
        (cell as? CustomReactionCollectionViewCell)?.configureCell(emoji: "\(emoji.display)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = viewModel.allEmojis[indexPath.section][indexPath.row]
        viewModel.addToRecentEmojis(emoji: selectedEmoji)
        selectedEmojiPublisher.send(selectedEmoji.display)
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

extension CustomReactionsViewController: UIEditMenuInteractionDelegate {
    func setupVariations(emoji: Emoji) -> Bool {
        guard let variations = emoji.variationsToShow else {
            self.actions = nil
            return false }
        var options: [UIAction] = []
        
        variations.forEach { variation in
            let option = UIAction(title: variation) { [weak self] _ in
                self?.selectedEmojiPublisher.send(variation)
                self?.dismiss(animated: true)
            }
            options.append(option)
        }
        self.actions = options
        return true
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let collectionView = mainView.collectionView
        guard sender.state == .began,
              let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView))
        else { return }
        let emoji = viewModel.allEmojis[indexPath.section][indexPath.row]
        guard setupVariations(emoji: emoji) else { return }
        if #available(iOS 16.0, *) {
            let a = UIEditMenuInteraction(delegate: self)
            mainView.collectionView.addInteraction(a)
            a.presentEditMenu(with: UIEditMenuConfiguration(identifier: nil, sourcePoint: sender.location(in: collectionView)))
        }
    }
    
    @available(iOS 16.0, *)
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard let actions else { return nil }
        let customMenu = UIMenu(title: "", options: .displayInline, children: actions)
        return UIMenu(children: customMenu.children)
    }
}
