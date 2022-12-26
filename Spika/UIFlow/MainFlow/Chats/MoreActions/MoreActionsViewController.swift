//
//  MoreActionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.12.2022..
//

import UIKit

class MoreActionsViewController: BaseViewController {
    let moreActionsView = MoreActionsView()
    var viewModel: MoreActionsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(moreActionsView)
        moreActionsView.fillSuperview()
        setupBindings()
    }
}

extension MoreActionsViewController {
    func setupBindings() {
        moreActionsView.publisher.sink { [weak self] state in
            switch state {
            case .files:
                break
            case .library:
                break
            case .location:
                break
            case .contact:
                break
            case .close:
                self?.dismiss(animated: true)
            }
        }.store(in: &subscriptions)
    }
}
