//
//  SharedViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class SharedViewController: BaseViewController {
    
    private let sharedView = SharedView()
    var viewModel: SharedViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(sharedView)
        setupBindings()
        navigationItem.title = .getStringFor(.sharedMediaLinksDocs)
    }
    
    func setupBindings() {
        sharedView.mediaCollectionView.delegate = self
        sharedView.mediaCollectionView.dataSource = self
        sharedView.docsTableView.delegate = self
        sharedView.docsTableView.dataSource = self
        sharedView.linksTableView.delegate = self
        sharedView.linksTableView.dataSource = self
    }
}

extension SharedViewController: UITableViewDelegate {
    
}

extension SharedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch sharedView.segmentedControl.selectedSegmentIndex {
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sharedView.segmentedControl.selectedSegmentIndex {
        case 1:
            return "Test1"
        case 2:
            return "Test2"
        default:
            return "Default"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sharedView.segmentedControl.selectedSegmentIndex {
        case 1:
            return 4
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch sharedView.segmentedControl.selectedSegmentIndex {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: LinksTableViewCell.reuseIdentifier) as? LinksTableViewCell
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: DocsTableViewCell.reuseIdentifier) as? DocsTableViewCell
        default:
            return UnknownTableViewCell()
        }
        return cell ?? UnknownTableViewCell()
    }
}

extension SharedViewController: UICollectionViewDelegate {
    
}

extension SharedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: MediaCollectionViewCell.reuseIdentifier, for: indexPath)
    }
}

extension SharedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4 - 1,
               height: collectionView.frame.width / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
