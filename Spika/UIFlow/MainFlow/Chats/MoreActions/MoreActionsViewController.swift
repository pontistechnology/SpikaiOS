//
//  MoreActionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.12.2022..
//

import UIKit
import Combine

class MoreActionsViewController: BaseViewController {
    private let moreActionsView = MoreActionsView()
    var viewModel: MoreActionsViewModel!
    
    let publisher = PassthroughSubject<MoreActions, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(moreActionsView)
        moreActionsView.fillSuperview()
        setupBindings()
    }
}

private extension MoreActionsViewController {
    func setupBindings() {
        moreActionsView.closeImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.close)
        }.store(in: &subscriptions)
        
        moreActionsView.filesImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.files)
        }.store(in: &subscriptions)
        
        moreActionsView.libraryImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.library)
        }.store(in: &subscriptions)
        
        moreActionsView.contactImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.contact)
        }.store(in: &subscriptions)
        
        moreActionsView.locationImageView.tap().sink { [weak self] _ in
            self?.publisher.send(.location)
        }.store(in: &subscriptions)
        
        moreActionsView.transparentView.tap().sink { [weak self] _ in
            self?.publisher.send(.close)
        }.store(in: &subscriptions)
    }
}
