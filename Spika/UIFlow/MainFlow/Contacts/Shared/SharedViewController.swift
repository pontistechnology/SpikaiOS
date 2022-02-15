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
        navigationItem.title = "Shared Media, Docs and Links"
    }
    
    func setupBindings() {
        sharedView.mediaView.collectionView.delegate = self
        sharedView.mediaView.collectionView.dataSource = self
        sharedView.docsView.tableView.delegate = self
        sharedView.docsView.tableView.dataSource = self
        sharedView.linksView.tableView.delegate = self
        sharedView.linksView.tableView.dataSource = self
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
            return UITableViewCell()
        }
        return cell ?? UITableViewCell()
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
