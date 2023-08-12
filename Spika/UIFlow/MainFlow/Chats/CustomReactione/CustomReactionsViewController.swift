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
    private let mainView = CustomReactionsView()
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
    }
}

extension CustomReactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        6
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

